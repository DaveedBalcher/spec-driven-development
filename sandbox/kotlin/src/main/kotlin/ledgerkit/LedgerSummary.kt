package ledgerkit

import java.time.Instant
import java.time.ZoneOffset

/** One day's worth of the ledger. */
data class DaySection(
    /** The calendar date of [Transaction.postedAt] in UTC, as `YYYY-MM-DD`. */
    val day: String,
    val transactions: List<Transaction>,
    /** The sum of every [Transaction.amountMinor] in [transactions]. */
    val totalMinor: Long,
)

/**
 * Groups a ledger into day sections.
 *
 * This is the naive version, and it is naive in three ways that a later change
 * has to deal with: declined transactions are counted in the total, pending ones
 * are not called out separately, and amounts in different currencies are added
 * together as if they were the same number.
 */
object LedgerSummary {

    /** Oldest day first. Days with no transactions do not appear at all. */
    fun byDay(transactions: List<Transaction>): List<DaySection> {
        val buckets = LinkedHashMap<String, MutableList<Transaction>>()
        for (transaction in transactions) {
            buckets.getOrPut(day(transaction.postedAt)) { mutableListOf() }.add(transaction)
        }
        return buckets.entries
            .sortedBy { it.key }
            .map { (day, rows) ->
                DaySection(
                    day = day,
                    transactions = rows.sortedBy { it.postedAt },
                    totalMinor = rows.sumOf { it.amountMinor },
                )
            }
    }

    /** `YYYY-MM-DD` in UTC, built by hand so no formatter and no locale is involved. */
    fun day(instant: Instant): String {
        val date = instant.atOffset(ZoneOffset.UTC).toLocalDate()
        return pad(date.year, 4) + "-" + pad(date.monthValue, 2) + "-" + pad(date.dayOfMonth, 2)
    }

    private fun pad(value: Int, width: Int): String {
        var text = value.toString()
        while (text.length < width) {
            text = "0" + text
        }
        return text
    }
}
