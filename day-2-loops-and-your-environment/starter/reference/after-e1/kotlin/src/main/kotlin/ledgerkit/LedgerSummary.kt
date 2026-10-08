package ledgerkit

import java.time.Instant
import java.time.ZoneOffset

/** One currency's money on one day. */
data class CurrencyTotal(
    val currency: String,
    val postedMinor: Long,
    val pendingMinor: Long,
)

/** One day's worth of the ledger, with per-currency totals. */
data class DaySection(
    val day: String,
    val transactions: List<Transaction>,
    val totals: List<CurrencyTotal>,
)

/**
 * Change B, as one unattended run produced it. The suite it left behind is
 * green. It is also wrong in six places, which is the point: this file is the
 * input to Day 2's Exercise 2, not a reference implementation.
 */
object LedgerSummary {

    fun byDay(transactions: List<Transaction>): List<DaySection> {
        val buckets = LinkedHashMap<String, MutableList<Transaction>>()
        for (transaction in transactions) {
            buckets.getOrPut(day(transaction.postedAt)) { mutableListOf() }.add(transaction)
        }
        return buckets.keys
            .sorted()
            .map { day ->
                val rows = buckets.getValue(day)
                    .sortedWith(compareByDescending<Transaction> { it.postedAt }.thenByDescending { it.id })
                DaySection(day = day, transactions = rows, totals = totals(rows))
            }
    }

    private fun totals(rows: List<Transaction>): List<CurrencyTotal> {
        val pendingForTheDay = rows
            .filter { it.status == TransactionStatus.PENDING }
            .sumOf { it.amountMinor }

        val order = mutableListOf<String>()
        val posted = HashMap<String, Long>()
        for (row in rows) {
            if (!order.contains(row.currency)) {
                order.add(row.currency)
                posted[row.currency] = 0L
            }
            if (row.status != TransactionStatus.PENDING) {
                posted[row.currency] = (posted[row.currency] ?: 0L) + row.amountMinor
            }
        }

        return order.map { currency ->
            CurrencyTotal(
                currency = currency,
                postedMinor = posted[currency] ?: 0L,
                pendingMinor = pendingForTheDay,
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
