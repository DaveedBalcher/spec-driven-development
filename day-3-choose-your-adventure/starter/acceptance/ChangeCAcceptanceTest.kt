package ledgerkit

import java.time.Instant
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * The hidden acceptance suite for Change C, Kotlin lane.
 *
 * It is written from the brief and nothing else, it is identical in intent to
 * the Swift lane's copy, and it stays outside the repository until the exercise
 * copies it in, so no framework can read it while it plans or repairs. Two of
 * the six tests encode the brief's two ambiguities: a red result there says
 * which way your framework decided, not that you failed.
 */
class ChangeCAcceptanceTest {

    // The cycle table, loaded from the test resources the exercise copies it into.
    private fun cycleTable(): String {
        val stream = javaClass.getResourceAsStream("/cycle-config.tsv")
        checkNotNull(stream) { "cycle-config.tsv is not on the test classpath - copy it into src/test/resources/" }
        return stream.bufferedReader().use { it.readText() }
    }

    private fun cycle(name: String): StatementCycle =
        assertNotNull(
            StatementCycle.parse(cycleTable(), name),
            "the cycle table should carry a configuration named $name",
        )

    private fun transaction(id: String, posted: String, authorized: String) = Transaction(
        id = id,
        postedAt = Instant.parse(posted),
        authorizedAt = Instant.parse(authorized),
        merchant = "Fixture Merchant",
        amountMinor = -1000L,
        currency = "USD",
        status = TransactionStatus.POSTED,
        category = Category.OTHER,
    )

    @Test
    fun testCycleConfigLoadsFromTheFixture() {
        val table = cycleTable()

        val standard = assertNotNull(StatementCycle.parse(table, "standard"))
        assertEquals(1, standard.rules.size, "the standard configuration ships one rule")
        assertEquals("2026-01-01", standard.rules.first().effectiveFrom)
        assertEquals(5, standard.rules.first().startDay)

        val monthEnd = assertNotNull(StatementCycle.parse(table, "month-end"))
        assertEquals(31, monthEnd.rules.first().startDay)

        assertNull(
            StatementCycle.parse(table, "no-such-configuration"),
            "a name that is not in the table has no configuration",
        )
    }

    @Test
    fun testPeriodBoundariesForTheStandardCycle() {
        val periods = StatementPeriods.periods(Fixture.transactions, cycle("standard"))

        assertEquals(2, periods.size, "the fixture spans two periods of a cycle starting on the 5th")
        assertEquals("2026-03-05", periods[0].start, "newest period first")
        assertEquals("2026-04-04", periods[0].end, "the end date is the last day covered")
        assertEquals("2026-02-05", periods[1].start)
        assertEquals("2026-03-04", periods[1].end, "periods run back to back with no gap")
    }

    @Test
    fun testEveryTransactionLandsInExactlyOnePeriod() {
        val all = Fixture.transactions
        val periods = StatementPeriods.periods(all, cycle("standard"))

        val placed = periods.flatMap { section -> section.transactions.map { it.id } }
        assertEquals(all.size, placed.size, "every transaction is placed once and only once")
        assertEquals(all.map { it.id }.toSet(), placed.toSet())
        assertEquals(7, periods[0].transactions.size)
        assertEquals(13, periods[1].transactions.size)
    }

    /**
     * Ambiguity one. LK-015 was authorized on 2026-03-04, inside the period that
     * ends that day, and posted on 2026-03-05, the first day of the next one.
     * This suite reads membership from the posted date.
     */
    @Test
    fun testAuthorizedVsPostedMembership() {
        val periods = StatementPeriods.periods(Fixture.transactions, cycle("standard"))
        val newest = periods[0].transactions.map { it.id }
        val older = periods[1].transactions.map { it.id }

        assertTrue(
            newest.contains("LK-015"),
            "LK-015 posted on 2026-03-05 and belongs to the period that opens that day",
        )
        assertFalse(newest.contains("LK-011"), "LK-011 posted on 2026-03-04, inside the earlier period")
        assertTrue(older.contains("LK-011"), "LK-011 was authorized on 2026-03-03 and posted on 2026-03-04")
        assertFalse(older.contains("LK-015"))
    }

    /**
     * Ambiguity two. A cycle that starts on day 31 has no 31st in February, so
     * this suite holds the start day inside the month: 2026-02-28.
     */
    @Test
    fun testFebruaryCycleStart() {
        val transactions = listOf(
            transaction("T-FEB", "2026-02-15T12:00:00Z", "2026-02-15T12:00:00Z"),
            transaction("T-MAR", "2026-02-28T12:00:00Z", "2026-02-28T12:00:00Z"),
        )
        val periods = StatementPeriods.periods(transactions, cycle("month-end"))

        assertEquals(2, periods.size)
        assertEquals("2026-02-28", periods[0].start, "February is 28 days long in 2026, so day 31 lands on the 28th")
        assertEquals("2026-03-30", periods[0].end)
        assertEquals(listOf("T-MAR"), periods[0].transactions.map { it.id })
        assertEquals("2026-01-31", periods[1].start)
        assertEquals("2026-02-27", periods[1].end)
        assertEquals(listOf("T-FEB"), periods[1].transactions.map { it.id })
    }

    @Test
    fun testPeriodListsEveryStatusOldestFirst() {
        val periods = StatementPeriods.periods(Fixture.transactions, cycle("standard"))
        val newest = periods[0].transactions

        assertEquals(
            listOf("LK-014", "LK-015", "LK-016", "LK-017", "LK-018", "LK-019", "LK-020"),
            newest.map { it.id },
            "inside a period the transactions read oldest first",
        )
        val statuses = newest.map { it.status }.toSet()
        assertTrue(statuses.contains(TransactionStatus.PENDING), "a pending row belongs on the statement it posted to")
        assertTrue(statuses.contains(TransactionStatus.DECLINED), "so does a declined one")
    }
}
