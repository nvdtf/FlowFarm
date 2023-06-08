import FlowFarm from "../../contracts/FlowFarm.cdc"
import Strawberry from "../../contracts/tokens/Strawberry.cdc"
import FungibleToken from "../../contracts/standards/FungibleToken.cdc"

transaction {
    prepare(account: AuthAccount) {

        // load farm from storage
        let farm <- account.load<@FlowFarm.Farm>(from: /storage/myFarm)!

        // harvest strawberries
        let strawberries <- farm.field.harvest()

        // check if account is initialized to receive strawberries
        if account.borrow<&Strawberry.Vault>(from: Strawberry.VaultStoragePath) == nil {
            // if not, create empty vault
            account.save(
                <-Strawberry.createEmptyVault(),
                to: Strawberry.VaultStoragePath
            )
        }

        // deposit strawberries into storage
        let vault = account.borrow<&Strawberry.Vault>(from: Strawberry.VaultStoragePath)!
        vault.deposit(from: <- strawberries)

        // withdraw Farmer
        let farmer <- farm.field.withdrawFarmer()
        destroy farmer

        // save Farm back to storage
        account.save(<-farm, to: /storage/myFarm)
    }
}