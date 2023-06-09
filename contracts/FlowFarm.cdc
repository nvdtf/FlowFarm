import Strawberry from "./tokens/Strawberry.cdc"
import StrawberrySeed from "./tokens/StrawberrySeed.cdc"

pub contract FlowFarm {

    // number of blocks that needs to pass after seeds are
    // planted before they are ready to harvest
    pub let SEED_GROWTH_TIME_IN_HEIGHT: UInt64

    // number of blocks that farmer needs to work on the
    // field before strawberries are ready
    pub let HARVEST_TIME_IN_HEIGHT: UInt64

    // Farmer can work on the field to produce strawberries
    pub resource Farmer {

        // energy is used when harvesting strawberries
        pub var energy: UFix64

        init(energy: UFix64) {
            self.energy = energy
        }

        access(contract) fun useEnergy(amount: UFix64) {
            pre {
                amount <= self.energy: "Not enough energy"
            }
            self.energy = self.energy - amount
        }
    }

    // everyone can create Farmer
    pub fun newFarmer(energy: UFix64): @Farmer {
        return <- create Farmer(energy: energy)
    }

    // Farm resource contains the field resource
    pub resource Farm {

        // single field per farm for now
        pub let field: @Field

        init() {
            self.field <- create Field()
        }

        destroy() {
            destroy self.field
        }
    }

    // everyone can create Farm
    pub fun newFarm(): @Farm {
        return <- create Farm()
    }

    // Field is used to plant seeds and employ farmer to harvest
    pub resource Field {

        // store the seeds and the height they are planted
        pub var seeds: @StrawberrySeed.Vault?
        pub var seedsPlantedHeight: UInt64?

        // store the farmer and the height one is employed
        pub var farmer: @Farmer?
        pub var farmerEmployedHeight: UInt64?

        init() {
            self.seeds <- nil
            self.seedsPlantedHeight = nil
            self.farmer <- nil
            self.farmerEmployedHeight = nil
        }

        // plant seeds on the field
        pub fun plant(seeds: @StrawberrySeed.Vault) {
            pre {
               self.seeds == nil: "Seeds already planted"
            }
            let old <- self.seeds <- seeds
            destroy old
            self.seedsPlantedHeight = getCurrentBlock().height
        }

        // employ farmer to harvest the field
        pub fun employ(farmer: @Farmer) {
            pre {
               self.farmer == nil: "Farmer already registered"
               self.seeds != nil: "No seeds are planted"

               getCurrentBlock().height - self.seedsPlantedHeight!
                    >= FlowFarm.HARVEST_TIME_IN_HEIGHT
                    : "Seeds are still growing"
            }
            let old <- self.farmer <- farmer
            destroy old
            self.farmerEmployedHeight = getCurrentBlock().height
        }

        // harvest and return the yield (strawberries)
        pub fun harvest(): @Strawberry.Vault {
            pre {
               self.farmer != nil: "No farmer employed"
               self.seeds != nil: "No seeds are planted"

               getCurrentBlock().height - self.seedsPlantedHeight!
                    >= FlowFarm.SEED_GROWTH_TIME_IN_HEIGHT
                    : "Seeds not ready to harvest"

               getCurrentBlock().height - self.farmerEmployedHeight!
                    >= FlowFarm.HARVEST_TIME_IN_HEIGHT
                    : "Farmer still working"

               self.farmerEmployedHeight! >= self.seedsPlantedHeight!
                    : "Seeds planted after farmer employed"
            }

            let f <- self.farmer <- nil
            let farmer <- f!
            let s <- self.seeds <- nil
            let seeds <- s!

            let yield = seeds.balance

            // Farmer spends energy to harvest
            farmer.useEnergy(amount: yield)

            // seeds are destroyed 1:1 for strawberries
            destroy seeds
            let strawberries
                <- Strawberry.mintTokens(amount: yield)

            self.farmer <-! farmer
            return <- strawberries
        }

        // withdraw farmer from the field
        pub fun withdrawFarmer(): @Farmer? {
            let f <- self.farmer <- nil
            return <- f
        }

        destroy () {
            destroy self.farmer
            destroy self.seeds
        }
    }

    init() {
        self.SEED_GROWTH_TIME_IN_HEIGHT = 10
        self.HARVEST_TIME_IN_HEIGHT = 3
    }
}