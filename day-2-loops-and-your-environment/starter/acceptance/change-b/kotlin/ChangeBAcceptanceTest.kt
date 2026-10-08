package ledgerkit

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * The hidden acceptance suite for Change B.
 *
 * Written against `specs/daily-summary.md` and the two sharpenings the
 * reference audit routes into it, not against anybody's implementation. Six
 * assertions, one per reference finding, in finding order. A failure here names
 * the finding you did not route.
 *
 * Copy this file into the lane's test tree after your own run:
 *
 *     cp -R day-2-loops-and-your-environment/starter/acceptance/change-b/kotlin/. \
 *           day2-work/src/test/kotlin/
 */
class ChangeBAcceptanceTest {

    private val sections = LedgerSummary.byDay(Fixture.transactions)

    private fun section(day: String): DaySection =
        sections.firstOrNull { it.day == day }
            ?: error("no day section for $day; byDay returned ${sections.map { it.day }}")

    private fun total(currency: String, day: String): CurrencyTotal? =
        section(day).totals.firstOrNull { it.currency == currency }

    /**
     * Finding 1, criterion 1: a declined amount is in no total. LK-006 is a
     * declined USD row for -13999 on 2026-03-03. The only other USD row that
     * day, LK-005, is pending, so the posted figure is zero.
     */
    @Test
    fun `acceptance 1 declined amounts are in no total`() {
        assertTrue(
            section("2026-03-03").transactions.any { it.id == "LK-006" },
            "criterion 1: the declined row is still listed",
        )
        assertEquals(
            0L,
            total("USD", "2026-03-03")?.postedMinor,
            "criterion 1: LK-006 (-13999, declined) must not be counted",
        )
    }

    /**
     * Finding 2, criterion 2: the pending figure is per currency, not per day.
     * On 2026-03-05 the only pending row is LK-016, in GBP.
     */
    @Test
    fun `acceptance 2 pending totals are per currency`() {
        assertEquals(
            -9630L,
            total("GBP", "2026-03-05")?.pendingMinor,
            "criterion 2: GBP carries its own pending sum",
        )
        assertEquals(
            0L,
            total("BHD", "2026-03-05")?.pendingMinor,
            "criterion 2: BHD has no pending row, so its pending figure is zero",
        )
        assertEquals(
            0L,
            total("GBP", "2026-03-05")?.postedMinor,
            "criterion 2: a pending row is never counted as posted",
        )
    }

    /** Finding 3, criterion 3: sections come back newest day first. */
    @Test
    fun `acceptance 3 sections are newest day first`() {
        assertEquals(
            listOf("2026-03-06", "2026-03-05", "2026-03-04", "2026-03-03", "2026-03-02"),
            sections.map { it.day },
            "criterion 3: newest day first, and no day without transactions",
        )
    }

    /** Finding 4, routed into criterion 3: rows inside a day stay oldest first. */
    @Test
    fun `acceptance 4 rows inside a day are oldest first`() {
        assertEquals(
            listOf("LK-009", "LK-010", "LK-011", "LK-012", "LK-013"),
            section("2026-03-04").transactions.map { it.id },
            "criterion 3, sharpened: the day flips, the rows inside it do not",
        )
    }

    /**
     * Finding 5, routed into criterion 4: a currency whose only row that day was
     * declined has no money to report and gets no entry. LK-017 is the only EUR
     * row on 2026-03-05, and it was declined.
     */
    @Test
    fun `acceptance 5 a declined-only currency has no entry`() {
        assertTrue(
            section("2026-03-05").transactions.any { it.id == "LK-017" },
            "the declined row is still listed",
        )
        assertNull(
            total("EUR", "2026-03-05"),
            "criterion 4, sharpened: no entry for a currency with no posted or pending row",
        )
    }

    /**
     * Finding 6, criterion 4: totals are ordered by currency code ascending, and
     * no two currencies are added together.
     */
    @Test
    fun `acceptance 6 totals are in currency code order`() {
        assertEquals(
            listOf("EUR", "GBP", "USD"),
            section("2026-03-06").totals.map { it.currency },
            "criterion 4: ordered by code, not by the order the rows arrived in",
        )
        assertEquals(-1234567L, total("EUR", "2026-03-06")?.postedMinor)
        assertEquals(1299L, total("GBP", "2026-03-06")?.postedMinor)
        assertEquals(250000L, total("USD", "2026-03-06")?.pendingMinor)
    }
}
