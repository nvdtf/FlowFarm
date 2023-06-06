package test

import (
	"testing"

	"github.com/bjartek/overflow"
)

func TestFarmOwner(y *testing.T) {

	o := overflow.Overflow()

	o.Tx(
		"owner/1_plant",
		overflow.WithSigner("owner"),
	)

	noop(o, 10)

	o.Tx(
		"owner/2_employ",
		overflow.WithSigner("owner"),
	)

	noop(o, 10)

	o.Tx(
		"owner/3_harvest",
		overflow.WithSigner("owner"),
	)

}

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
