package test

import (
	"testing"

	"github.com/bjartek/overflow"
)

// Owner creates a farm, plants seeds, employs a worker and harvests the crop
func TestFarmOwner(t *testing.T) {

	// Start emulator and deploy contracts
	o := overflow.Overflow()

	// Step 1: Create a farm and plant seeds
	o.Tx(
		"owner/1_plant",
		overflow.WithSigner("owner"),
	).AssertSuccess(t).
		AssertEvent(t, "StrawberrySeed.TokensMinted", map[string]interface{}{
			"amount": 10.0,
		}).
		AssertEvent(t, "FlowFarm.SeedsPlanted", map[string]interface{}{
			"amount": 10.0,
		})

	// Advance 10 blocks
	noop(o, 10)

	// Step 2: Employ a worker to start harvesting
	o.Tx(
		"owner/2_employ",
		overflow.WithSigner("owner"),
	).AssertSuccess(t).
		AssertEmitEventName(t, "FlowFarm.FarmerEmployed")

	// Advance 10 blocks
	noop(o, 10)

	// Step 3: Harvest the strawberries
	o.Tx(
		"owner/3_harvest",
		overflow.WithSigner("owner"),
	).AssertSuccess(t).
		AssertEmitEventName(t, "FlowFarm.FarmerRetired").
		AssertEvent(t, "FlowFarm.StrawberryHarvested", map[string]interface{}{
			"amount": 10.0,
		}).
		AssertEvent(t, "FlowFarm.FarmerEnergyUsed", map[string]interface{}{
			"amount": 10.0,
		}).
		AssertEvent(t, "Strawberry.TokensMinted", map[string]interface{}{
			"amount": 10.0,
		}).
		AssertEvent(t, "Strawberry.TokensDeposited", map[string]interface{}{
			"amount": 10.0,
			"to":     "0x179b6b1cb6755e31",
		})

}

func TestPickingContract(t *testing.T) {

	// Start emulator and deploy contracts
	o := overflow.Overflow(overflow.WithFlowForNewUsers(100))

	// Step 1: Create a farm and plant seeds. Create a new contract so another
	// player can deposit their Farmer
	o.Tx(
		"contractor/1_issue",
		overflow.WithSigner("owner"),
	).AssertSuccess(t).
		AssertEvent(t, "StrawberrySeed.TokensMinted", map[string]interface{}{
			"amount": 10.0,
		}).
		AssertEvent(t, "FlowFarm.SeedsPlanted", map[string]interface{}{
			"amount": 10.0,
		})

	// Advance 10 blocks
	noop(o, 10)

	// Step 2: Another user creates a Farmer and employs them for harvesting.
	o.Tx(
		"contractor/2_employ",
		overflow.WithArg("contractAddress", "owner"),
		overflow.WithSigner("contractor"),
	).AssertSuccess(t).
		AssertEmitEventName(t, "FlowFarm.FarmerEmployed").
		AssertEvent(t, "FlowToken.TokensDeposited", map[string]interface{}{
			"amount": 10.0,
		})

	// Advance 10 blocks
	noop(o, 10)

	// Step 3: Withdraw Farmer
	o.Tx(
		"contractor/3_withdraw",
		overflow.WithArg("contractAddress", "owner"),
		overflow.WithSigner("contractor"),
	).AssertSuccess(t).
		AssertEmitEventName(t, "FlowFarm.FarmerRetired").
		AssertEvent(t, "FlowFarm.StrawberryHarvested", map[string]interface{}{
			"amount": 10.0,
		}).
		AssertEvent(t, "FlowFarm.FarmerEnergyUsed", map[string]interface{}{
			"amount": 10.0,
		}).
		AssertEvent(t, "Strawberry.TokensMinted", map[string]interface{}{
			"amount": 10.0,
		}).
		AssertEvent(t, "Strawberry.TokensDeposited", map[string]interface{}{
			"amount": 10.0,
			"to":     "0x179b6b1cb6755e31",
		})

}

// noop runs a noop transaction to advance block height in emulator
func noop(o *overflow.OverflowState, num int) {
	i := 0
	for i < num {
		o.Tx(
			"noop",
			overflow.WithSigner("owner"),
		)
		i += 1
	}
}
