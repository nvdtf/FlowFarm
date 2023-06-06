import FlowFarm from "../../contracts/FlowFarm.cdc"
import Strawberry from "../../contracts/Strawberry.cdc"
import FungibleToken from "../../contracts/standards/FungibleToken.cdc"

transaction {

    prepare(account: AuthAccount) {

        let farm <- account.load<@FlowFarm.Farm>(from: /storage/myFarm)!

        let strawberries <- farm.field.farm()

        if account.borrow<&Strawberry.Vault>(from: Strawberry.VaultStoragePath) == nil {
            account.save(
                <-Strawberry.createEmptyVault(),
                to: Strawberry.VaultStoragePath
            )

            account.link<&Strawberry.Vault{FungibleToken.Receiver}>(
                Strawberry.ReceiverPublicPath,
                target: Strawberry.VaultStoragePath
            )

            account.link<&Strawberry.Vault{FungibleToken.Balance}>(
                Strawberry.VaultPublicPath,
                target: Strawberry.VaultStoragePath
            )
        }

        let vault = account.borrow<&Strawberry.Vault>(from: Strawberry.VaultStoragePath)!
        vault.deposit(from: <- strawberries)

        let farmer <- farm.field.withdrawFarmer()
        destroy farmer

        account.save(<-farm, to: /storage/myFarm)

    }

}