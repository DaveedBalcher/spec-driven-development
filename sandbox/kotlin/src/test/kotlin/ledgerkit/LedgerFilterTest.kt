package ledgerkit

import java.time.Instant
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class LedgerFilterTest {

    private val all = Fixture.transactions

    private fun ids(query: Query): List<String> =
        LedgerFilter.apply(all, query).map { it.id }

    @Test
    fun `an empty query keeps everything`() {
        assertEquals(20, ids(Query()).size)
    }

    @Test
    fun `folding lower cases and strips diacritics`() {
        assertEquals("cafe muller", LedgerFilter.fold("Café Müller"))
        assertEquals("zurich transit", LedgerFilter.fold("ZÜRICH TRANSIT"))
        assertEquals("norrebro bakeri", LedgerFilter.fold("Nørrebro Bakeri"))
    }

    @Test
    fun `merchant matching ignores case and diacritics`() {
        assertEquals(listOf("LK-003", "LK-009", "LK-010"), ids(Query(merchantContains = "cafe muller")))
        assertEquals(listOf("LK-004", "LK-011", "LK-018"), ids(Query(merchantContains = "zurich transit")))
    }

    @Test
    fun `status narrows the result`() {
        assertEquals(listOf("LK-006", "LK-017"), ids(Query(statuses = setOf(TransactionStatus.DECLINED))))
        assertEquals(
            listOf("LK-005", "LK-016", "LK-020"),
            ids(Query(statuses = setOf(TransactionStatus.PENDING))),
        )
    }

    @Test
    fun `category narrows the result`() {
        assertEquals(listOf("LK-012", "LK-016", "LK-017"), ids(Query(categories = setOf(Category.BILLS))))
    }

    @Test
    fun `the date range is inclusive at both ends and reads postedAt`() {
        val query = Query(
            from = Instant.parse("2026-03-03T00:00:00Z"),
            to = Instant.parse("2026-03-03T23:59:59Z"),
        )
        assertEquals(listOf("LK-004", "LK-005", "LK-006", "LK-007", "LK-008"), ids(query))
    }

    @Test
    fun `the fields of a query are combined with and`() {
        val query = Query(
            statuses = setOf(TransactionStatus.POSTED),
            categories = setOf(Category.DINING),
            merchantContains = "CAFE",
        )
        assertEquals(listOf("LK-003", "LK-009", "LK-010"), ids(query))
    }

    @Test
    fun `a merchant substring that matches nothing returns nothing`() {
        assertTrue(ids(Query(merchantContains = "no such merchant")).isEmpty())
    }
}
