import FlowFarm from "./FlowFarm.cdc"
import FlowToken from "./standards/FlowToken.cdc"
import FungibleToken from "./standards/FungibleToken.cdc"
import Strawberry from "./tokens/Strawberry.cdc"

pub contract PickingContract {

    pub resource interface Contract {
        pub fun employ(farmer: @FlowFarm.Farmer): @FlowToken.Vault
        pub fun withdrawFarmer(): @FlowFarm.Farmer
    }

    pub resource StrawberryContract: Contract {

        pub let farmCap: Capability<&FlowFarm.Farm>
        pub var payment: @FlowToken.Vault?
        pub let strawberryReceiver: Capability<&Strawberry.Vault{FungibleToken.Receiver}>

        init(
            farmCap: Capability<&FlowFarm.Farm>,
            payment: @FlowToken.Vault,
            strawberryReceiver: Capability<&Strawberry.Vault{FungibleToken.Receiver}>
        ) {
            self.farmCap = farmCap
            self.payment <- payment
            self.strawberryReceiver = strawberryReceiver
        }

        pub fun employ(farmer: @FlowFarm.Farmer): @FlowToken.Vault {
            let farm = self.farmCap.borrow()!
            farm.field.employ(farmer: <-farmer)
            let payment <- self.payment <- nil
            return <- payment!
        }

        pub fun withdrawFarmer(): @FlowFarm.Farmer {

            let farm = self.farmCap.borrow()!

            // harvest strawberries before returning Farmer
            // harvest() fails if Farmer is still working
            let strawberries <- farm.field.harvest()

            // deposit yield into contract capability
            self.strawberryReceiver.borrow()!.deposit(from: <-strawberries)

            return <- farm.field.withdrawFarmer()!
        }

        destroy() {
            destroy self.payment
        }
    }

    pub fun newStrawberryPickingContract(
        farmCap: Capability<&FlowFarm.Farm>,
        payment: @FlowToken.Vault,
        strawberryReceiver: Capability<&Strawberry.Vault{FungibleToken.Receiver}>
    ): @PickingContract.StrawberryContract {
        return <- create StrawberryContract(
            farmCap: farmCap,
            payment: <-payment,
            strawberryReceiver: strawberryReceiver
        )
    }
}