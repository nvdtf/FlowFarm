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

        pub let farmCap: Capability<&{FlowFarm.Farmable}>
        pub var payment: @FlowToken.Vault?
        pub let strawberryReceiver: Capability<&Strawberry.Vault{FungibleToken.Receiver}>

        init(
            farmCap: Capability<&{FlowFarm.Farmable}>,
            payment: @FlowToken.Vault,
            strawberryReceiver: Capability<&Strawberry.Vault{FungibleToken.Receiver}>
        ) {
            self.farmCap = farmCap
            self.payment <- payment
            self.strawberryReceiver = strawberryReceiver
        }

        pub fun employ(farmer: @FlowFarm.Farmer): @FlowToken.Vault {
            self.farmCap.borrow()!.employ(farmer: <-farmer)
            let payment <- self.payment <- nil
            return <- payment!
        }

        pub fun withdrawFarmer(): @FlowFarm.Farmer {

            // harvest strawberries before returning Farmer
            // harvest() fails if Farmer is still working
            let strawberries <- self.farmCap.borrow()!.harvest()

            // deposit yield into contract capability
            self.strawberryReceiver.borrow()!.deposit(from: <-strawberries)

            return <- self.farmCap.borrow()!.withdrawFarmer()!
        }

        destroy() {
            destroy self.payment
        }
    }

    pub fun newStrawberryPickingContract(
        farmCap: Capability<&{FlowFarm.Farmable}>,
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