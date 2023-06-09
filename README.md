# FlowFarm
This is a PoC repository that demonstrates:
1. A Farm resource that contains a Field resource. Farm owner can plant StrawberrySeeds (fungible token) to get Strawberry (fungible token). In order to harvest Strawberry, a Farmer resource needs to work on the field with a required energy amount. In our first demonstration, we have a single user that creates the farm, seeds, and farmer and does all the farming on their own.
2. A PickingContract resource that enables the Farm owner to create a "contract", so another person can use their Farmer (and their energy) to harvest Strawberry for the Farm owner. The other player receives some FlowToken in return of their work.

## Testing
```
make test
```