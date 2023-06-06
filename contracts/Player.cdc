pub contract Player {

    pub resource Farmer {

        pub var energy: UFix64

        init(energy: UFix64) {
            self.energy = energy
        }

        pub fun useEnergy(amount: UFix64) {
            pre {
                amount <= self.energy: "Not enough energy"
            }
            self.energy = self.energy - amount
        }
    }

    pub fun newFarmer(energy: UFix64): @Farmer {
        return <- create Farmer(energy: energy)
    }

}