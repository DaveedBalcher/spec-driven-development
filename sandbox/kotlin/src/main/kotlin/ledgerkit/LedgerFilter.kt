package ledgerkit

import java.time.Instant

/**
 * What to keep. Every field is optional: an empty set or a null means "any".
 * The date range is inclusive at both ends and is applied to [Transaction.postedAt].
 */
data class Query(
    val statuses: Set<TransactionStatus> = emptySet(),
    val categories: Set<Category> = emptySet(),
    val from: Instant? = null,
    val to: Instant? = null,
    val merchantContains: String? = null,
)

/**
 * Selects transactions against a [Query].
 *
 * Merchant matching is case- and diacritic-insensitive, so `cafe muller` finds
 * `Café Müller` and `CAFÉ MÜLLER KIOSK`. The folding table is written out by
 * hand for the same reason the formatting is: no locale, same answer on every
 * machine and in both lanes.
 */
object LedgerFilter {

    fun apply(transactions: List<Transaction>, query: Query): List<Transaction> =
        transactions.filter { matches(it, query) }

    fun matches(transaction: Transaction, query: Query): Boolean {
        if (query.statuses.isNotEmpty() && transaction.status !in query.statuses) return false
        if (query.categories.isNotEmpty() && transaction.category !in query.categories) return false
        query.from?.let { if (transaction.postedAt < it) return false }
        query.to?.let { if (transaction.postedAt > it) return false }
        query.merchantContains?.let { needle ->
            if (needle.isNotEmpty() && !fold(transaction.merchant).contains(fold(needle))) return false
        }
        return true
    }

    /** Lower case with the diacritics taken off, so two spellings compare equal. */
    fun fold(text: String): String {
        val lowered = text.lowercase()
        val out = StringBuilder(lowered.length)
        for (character in lowered) {
            out.append(FOLDED[character] ?: character.toString())
        }
        return out.toString()
    }

    private val FOLDED: Map<Char, String> = buildMap {
        fun add(characters: String, replacement: String) {
            for (character in characters) put(character, replacement)
        }
        add("àáâãäåāăą", "a")
        add("çćč", "c")
        add("ďđ", "d")
        add("èéêëēĕėęě", "e")
        add("ìíîïĩīįı", "i")
        add("ł", "l")
        add("ñńň", "n")
        add("òóôõöøōŏő", "o")
        add("ŕř", "r")
        add("śšş", "s")
        add("ťţ", "t")
        add("ùúûüũūŭůű", "u")
        add("ýÿ", "y")
        add("źżž", "z")
        add("æ", "ae")
        add("œ", "oe")
        add("ß", "ss")
        add("þ", "th")
    }
}
