import Player from "./Player.cdc"
import Strawberry from "./Strawberry.cdc"
import StrawberrySeed from "./StrawberrySeed.cdc"

pub contract FlowFarm {

    pub let SEED_GROWTH_TIME: UInt64
    pub let HARVEST_TIME: UInt64

    pub resource Farm {

        pub let field: @Field

        init() {
            self.field <- create Field()
        }

        destroy() {
            destroy self.field
        }

    }

    pub fun newFarm(): @Farm {
        return <- create Farm()
    }

    pub resource interface Farmable {
        pub fun employ(farmer: @Player.Farmer)
        pub fun farm(): @Strawberry.Vault
        pub fun withdrawFarmer(): @Player.Farmer?
    }

    pub resource Field: Farmable {

        pub var seeds: @StrawberrySeed.Vault?
        pub var seedsPlantedHeight: UInt64?

        pub var farmer: @Player.Farmer?
        pub var farmerEmployedHeight: UInt64?

        init() {
            self.seeds <- nil
            self.seedsPlantedHeight = nil
            self.farmer <- nil
            self.farmerEmployedHeight = nil
        }

        pub fun employ(farmer: @Player.Farmer) {
            pre {
               self.farmer == nil: "Farmer already registered"
               self.seeds != nil: "No seeds to farm"
               getCurrentBlock().height - self.seedsPlantedHeight! >= FlowFarm.SEED_GROWTH_TIME: "Seeds are not ready to harvest"
            }
            let old <- self.farmer <- farmer
            destroy old
            self.farmerEmployedHeight = getCurrentBlock().height
        }

        pub fun plant(seeds: @StrawberrySeed.Vault) {
            pre {
               self.seeds == nil: "Seeds already planted"
            }
            let old <- self.seeds <- seeds
            destroy old
            self.seedsPlantedHeight = getCurrentBlock().height
        }

        pub fun farm(): @Strawberry.Vault {
            // fix farming algorithm
            pre {
               self.farmer != nil: "No farmer employed"
               self.seeds != nil: "No seeds are planted"
               getCurrentBlock().height - self.seedsPlantedHeight! >= FlowFarm.SEED_GROWTH_TIME: "Seeds not ready to harvest"
               getCurrentBlock().height - self.farmerEmployedHeight! >= FlowFarm.HARVEST_TIME: "Farmer still working"
               self.farmerEmployedHeight! >= self.seedsPlantedHeight!: "Seeds planted after farmer employed"
            }

            let f <- self.farmer <- nil
            let farmer <- f!
            let s <- self.seeds <- nil
            let seeds <- s!

            let yield = seeds.balance

            farmer.useEnergy(amount: yield)

            destroy seeds

            self.farmer <-! farmer

            return <- Strawberry.mintTokens(amount: yield)
        }

        pub fun withdrawFarmer(): @Player.Farmer? {
            let f <- self.farmer <- nil
            return <- f
        }

        destroy () {
            destroy self.farmer
            destroy self.seeds
        }

    }

    init() {
        self.SEED_GROWTH_TIME = 10
        self.HARVEST_TIME = 3
    }

}