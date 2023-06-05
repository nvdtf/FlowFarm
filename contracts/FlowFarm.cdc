import Strawberry from "./Strawberry.cdc"
import StrawberrySeed from "./StrawberrySeed.cdc"

pub contract FlowFarm {

    pub resource Farm {

        pub let field: @Field

        init() {
            self.field <- create Field()
        }

        destroy() {
            destroy self.field
        }

    }

    pub resource Field {

        pub let farmers: @{UInt64: Farmer}
        pub let plantedSeeds: @{UInt64: StrawberrySeed.Vault}

        init() {
            self.farmers <- {}
            self.plantedSeeds <- {}
        }

        pub fun employ(farmer: @Farmer): UInt64 {
            let old <- self.farmers.insert(
                    key: getCurrentBlock().height,
                    <- farmer
                )
            if old != nil {
                panic("Farmer already registered for height")
            }
            destroy old
            return getCurrentBlock().height
        }

        pub fun plant(seeds: @StrawberrySeed.Vault) {
            let old <- self.plantedSeeds.insert(
                    key: getCurrentBlock().height,
                    <- seeds
                )
            if old != nil {
                panic("Seeds already planted for height")
            }
            destroy old
        }

        pub fun farm(farmerHeight: UInt64): @Strawberry.Vault {

            let farmer <- self.farmers.remove(key: farmerHeight)
            if farmer == nil {
                panic("No farmer registered for height")
            }

            var energy = farmer!.energy

            self.plantedSeeds.forEachKey(fun (key: UInt64): Bool {
                let newEnergy: Int = Int(energy) - Int(self.plantedSeeds[key]!.balance)
                if newEnergy > 0 {
                    energy = UInt(newEnergy)
                    return true
                }
                return newEnergy >= 0
            })

            let old <- self.farmers.insert(key: farmerHeight, <- farmer!)
            destroy old

            return <- Strawberry.mintTokens(amount: 1.0)
        }

        pub fun retire(farmerHeight: UInt64): @Farmer {
            let farmer <- self.farmers[farmerHeight]
            if farmer == nil {
                panic("No farmer registered for height")
            }
            return <- farmer!
        }

        destroy () {
            destroy self.farmers
            destroy self.plantedSeeds
        }

    }

    pub resource Farmer {

        pub var energy: UInt

        init(energy: UInt) {
            self.energy = energy
        }

        pub fun useEnergy(amount: UInt) {
            self.energy = self.energy - amount
        }
    }

}