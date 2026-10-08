package ledgerkit

import java.time.Instant

/** Where a transaction is in its life. */
enum class TransactionStatus {
    PENDING,
    POSTED,
    DECLINED;

    /** The wire form: lower case, as it appears in the fixture and in the API payload. */
    val wireName: String get() = name.lowercase()

    companion object {
        fun fromWire(raw: String): TransactionStatus =
            entries.firstOrNull { it.wireName == raw } ?: error("unknown status: $raw")
    }
}

/** The spending bucket a transaction was assigned. */
enum class Category {
    GROCERIES,
    TRANSPORT,
    DINING,
    BILLS,
    OTHER;

    val wireName: String get() = name.lowercase()

    companion object {
        fun fromWire(raw: String): Category =
            entries.firstOrNull { it.wireName == raw } ?: error("unknown category: $raw")
    }
}

/**
 * One row of the ledger.
 *
 * [amountMinor] is a signed integer in the currency's minor units: negative is a
 * debit (money leaving), positive is a credit (money coming back). There is never
 * a decimal point in this value; the decimal point is a rendering decision that
 * belongs to [TransactionFormatter].
 */
data class Transaction(
    val id: String,
    val postedAt: Instant,
    val authorizedAt: Instant,
    val merchant: String,
    val amountMinor: Long,
    val currency: String,
    val status: TransactionStatus,
    val category: Category,
)
