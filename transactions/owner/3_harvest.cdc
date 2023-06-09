import FlowFarm from "../../contracts/FlowFarm.cdc"
import Strawberry from "../../contracts/tokens/Strawberry.cdc"
import FungibleToken from "../../contracts/standards/FungibleToken.cdc"

transaction {
    prepare(owner: AuthAccount) {

        // load farm from storage
        let farm <- owner.load<@FlowFarm.Farm>(from: /storage/myFarm)!

        // harvest strawberries
        let strawberries <- farm.field.harvest()

        // initialize empty vault to store strawberries
        owner.save(
            <-Strawberry.createEmptyVault(),
            to: Strawberry.VaultStoragePath
        )

        // deposit strawberries into storage
        let vault = owner.borrow<&Strawberry.Vault>(from: Strawberry.VaultStoragePath)!
        vault.deposit(from: <- strawberries)

        // withdraw Farmer
        let farmer <- farm.field.withdrawFarmer()
        destroy farmer

        // save Farm back to storage
        owner.save(<-farm, to: /storage/myFarm)
    }
}