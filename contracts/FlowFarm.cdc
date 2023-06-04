import StrawberrySeeds from "./StrawberrySeeds.cdc"

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

        pub let farmers: @[Farmer]
        pub let seeds: @StrawberrySeeds.Vault

        init() {
            self.farmers <- []
            self.seeds <- StrawberrySeeds.createEmptyVault()
        }

        pub fun employ(farmer: @Farmer) {
            self.farmers.append(<- farmer)
        }

        destroy () {
            destroy self.farmers
            destroy self.seeds
        }

    }

    pub resource Farmer {

        pub let energy: UInt

        init(energy: UInt) {
            self.energy = energy
        }
    }

}