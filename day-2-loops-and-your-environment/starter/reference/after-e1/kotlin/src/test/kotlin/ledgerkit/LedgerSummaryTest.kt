package ledgerkit

import java.time.Instant
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

// Rewritten by the run. Every test here passes against the implementation the
// run produced, which is exactly why a green suite is not the end of the job.
class LedgerSummaryTest {

    private val sections = LedgerSummary.byDay(Fixture.transactions)

    private fun section(day: String): DaySection =
        sections.firstOrNull { it.day == day } ?: error("no section for $day")

    @Test
    fun `the day key is the UTC calendar date of postedAt`() {
        assertEquals("2026-03-04", LedgerSummary.day(Instant.parse("2026-03-04T03:12:44Z")))
    }

    @Test
    fun `one section per posted day`() {
        assertEquals(5, sections.map { it.day }.toSet().size)
    }

    @Test
    fun `a day with no transactions never appears`() {
        assertTrue(sections.all { it.transactions.isNotEmpty() })
        assertEquals(emptyList(), LedgerSummary.byDay(emptyList()))
    }

    @Test
    fun `declined rows are still listed`() {
        assertTrue(section("2026-03-03").transactions.any { it.id == "LK-006" })
    }

    @Test
    fun `each day has per currency totals`() {
        val third = section("2026-03-03")
        assertEquals(setOf("EUR", "GBP", "USD"), third.totals.map { it.currency }.toSet())
        assertEquals(-4890L, third.totals.first { it.currency == "EUR" }.postedMinor)
    }

    @Test
    fun `pending is reported separately`() {
        assertEquals(-1725L, section("2026-03-03").totals.first { it.currency == "USD" }.pendingMinor)
    }

    @Test
    fun `every transaction lands in exactly one section`() {
        assertEquals(20, sections.sumOf { it.transactions.size })
    }
}
