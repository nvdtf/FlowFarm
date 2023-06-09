import FlowFarm from "../../contracts/FlowFarm.cdc"
import PickingContract from "../../contracts/PickingContract.cdc"
import FungibleToken from "../../contracts/standards/FungibleToken.cdc"
import FlowToken from "../../contracts/standards/FlowToken.cdc"
import Strawberry from "../../contracts/tokens/Strawberry.cdc"
import StrawberrySeed from "../../contracts/tokens/StrawberrySeed.cdc"

transaction {
    prepare(owner: AuthAccount) {

        // create new Farm
        let farm <- FlowFarm.newFarm()

        // mint seeds
        let seeds <- StrawberrySeed.mintTokens(amount: 10.0)

        // plant seeds
        farm.field.plant(seeds: <- seeds)

        // save Farm to storage
        owner.save(<-farm, to: /storage/myFarm)

        // create capability to stored farm
        let farmCap = owner.link<&FlowFarm.Farm>(
            /private/myFarmCapability,
            target: /storage/myFarm
        )!

        // init strawberry receiver
        owner.save(
            <-Strawberry.createEmptyVault(),
            to: Strawberry.VaultStoragePath
        )
        let strawberryReceiver = owner.link<&Strawberry.Vault{FungibleToken.Receiver}>(
            Strawberry.ReceiverPublicPath,
            target: Strawberry.VaultStoragePath
        )!

        // init the bounty vault for contract
        let vaultRef = owner.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
			?? panic("Could not borrow reference to the owner's Vault!")
        let bounty <- vaultRef.withdraw(amount: 10.0) as! @FlowToken.Vault

        // create new picking contract
        let c <- PickingContract.newStrawberryPickingContract(
            farmCap: farmCap,
            payment: <- bounty,
            strawberryReceiver: strawberryReceiver
        )

        // store picking contract to storage
        owner.save(<-c, to: /storage/myPickingContract)

        // make contract available to public
        owner.link<&PickingContract.StrawberryContract{PickingContract.Contract}>(
            /public/strawberryContract01,
            target: /storage/myPickingContract
        )
    }
}