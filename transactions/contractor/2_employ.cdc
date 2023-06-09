import FlowFarm from "../../contracts/FlowFarm.cdc"
import PickingContract from "../../contracts/PickingContract.cdc"
import FlowToken from "../../contracts/standards/FlowToken.cdc"

transaction(
    contractAddress: Address,
) {
    prepare(contractor: AuthAccount) {

        // create a new Farmer
        let farmer <- FlowFarm.newFarmer(energy: 10.0)

        // load contract
        let contractRef = getAccount(contractAddress)
            .getCapability(/public/strawberryContract01)
            .borrow<&PickingContract.StrawberryContract{PickingContract.Contract}>()!

        // employ the Farmer
        let payment <- contractRef.employ(farmer: <-farmer)

        let vaultRef = contractor.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)!
        vaultRef.deposit(from: <-payment)

    }
}