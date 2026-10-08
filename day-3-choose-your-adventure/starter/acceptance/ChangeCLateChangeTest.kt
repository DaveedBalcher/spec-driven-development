package ledgerkit

import java.time.Instant
import kotlin.test.Test
import kotlin.test.assertEquals

/**
 * The assertions the late requirement adds, Kotlin lane.
 *
 * A cycle whose start day moves from the 5th to the 20th on 2026-04-01. Both
 * tests are red against an implementation that reads one rule and green once
 * the rule in force on a date decides where the next period opens. Run them
 * before you make the change as well as after: an assertion you never saw fail
 * has not been proved to bite.
 */
class ChangeCLateChangeTest {

    /** The 5th until 2026-04-01, the 20th from then on. */
    private fun movedCycle() = StatementCycle(
        listOf(
            CycleRule(effectiveFrom = "2026-01-01", startDay = 5),
            CycleRule(effectiveFrom = "2026-04-01", startDay = 20),
        ),
    )

    private fun transaction(id: String, posted: String) = Transaction(
        id = id,
        postedAt = Instant.parse(posted),
        authorizedAt = Instant.parse(posted),
        merchant = "Fixture Merchant",
        amountMinor = -1000L,
        currency = "USD",
        status = TransactionStatus.POSTED,
        category = Category.OTHER,
    )

    private fun ledger() = listOf(
        transaction("T-MAR", "2026-03-06T09:00:00Z"),
        transaction("T-APR", "2026-04-10T09:00:00Z"),
        transaction("T-LATE", "2026-04-25T09:00:00Z"),
    )

    @Test
    fun testStartDayMovesOnTheEffectiveDate() {
        val periods = StatementPeriods.periods(ledger(), movedCycle())

        assertEquals("2026-04-20", periods[0].start, "from 2026-04-01 the cycle opens on the 20th")
        assertEquals("2026-05-19", periods[0].end)
        assertEquals(listOf("T-LATE"), periods[0].transactions.map { it.id })

        val earlierDay = StatementCycle(
            listOf(
                CycleRule(effectiveFrom = "2026-01-01", startDay = 5),
                CycleRule(effectiveFrom = "2026-04-03", startDay = 2),
            ),
        )
        assertEquals(
            listOf("2026-03-05..2026-05-01"),
            StatementPeriods.periods(ledger(), earlierDay).map { "${it.start}..${it.end}" },
            "a move to the 2nd on 2026-04-03 first opens on 2026-05-02: 2026-04-02 is before the change",
        )
    }

    @Test
    fun testPeriodsBeforeTheChangeKeepTheOldStartDay() {
        val periods = StatementPeriods.periods(ledger(), movedCycle())

        assertEquals("2026-03-05", periods[1].start, "the period that opened under the old day keeps its start date")
        assertEquals(
            "2026-04-19",
            periods[1].end,
            "and runs to the day before the first boundary the new start day produces",
        )
        assertEquals(listOf("T-MAR", "T-APR"), periods[1].transactions.map { it.id }, "the change splits no period in two")
    }
}
