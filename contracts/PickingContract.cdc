import FlowFarm from "./FlowFarm.cdc"
import Player from "./Player.cdc"
import FlowToken from "./standards/FlowToken.cdc"
import FungibleToken from "./standards/FungibleToken.cdc"
import Strawberry from "./Strawberry.cdc"

pub contract PickingContract {

    pub resource Contract {

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

        pub fun employ(farmer: @Player.Farmer): @FlowToken.Vault {
            self.farmCap.borrow()!.employ(farmer: <-farmer)
            let payment <- self.payment <- nil
            return <- payment!
        }

        pub fun withdrawFarmer(): @Player.Farmer? {
            let strawberries <- self.farmCap.borrow()!.farm()
            self.strawberryReceiver.borrow()!.deposit(from: <-strawberries)
            return <- self.farmCap.borrow()!.withdrawFarmer()
        }

        destroy() {
            destroy self.payment
        }

    }

}