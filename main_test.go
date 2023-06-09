package test

import (
	"testing"

	"github.com/bjartek/overflow"
)

// Owner creates a farm, plants seeds, employs a worker and harvests the crop
func TestFarmOwner(y *testing.T) {

	o := overflow.Overflow()

	// Step 1: Create a farm and plant seeds
	o.Tx(
		"owner/1_plant",
		overflow.WithSigner("owner"),
	)

	// advance 10 blocks
	noop(o, 10)

	// Step 2: Employ a worker to start harvesting
	o.Tx(
		"owner/2_employ",
		overflow.WithSigner("owner"),
	)

	// advance 10 blocks
	noop(o, 10)

	// Step 3: Harvest the strawberries
	o.Tx(
		"owner/3_harvest",
		overflow.WithSigner("owner"),
	)

}

func TestPickingContract(y *testing.T) {

	o := overflow.Overflow()

	o.Tx(
		"contractor/1_issue",
		overflow.WithSigner("owner"),
	)

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
