import FlowFarm from "../../contracts/FlowFarm.cdc"
import PickingContract from "../../contracts/PickingContract.cdc"
import FlowToken from "../../contracts/standards/FlowToken.cdc"

transaction(
    contractAddress: Address,
) {
    prepare(contractor: AuthAccount) {

        // load contract
        let contractRef = getAccount(contractAddress)
            .getCapability(/public/strawberryContract01)
            .borrow<&PickingContract.StrawberryContract{PickingContract.Contract}>()!

        // withdraw the Farmer
        let farmer <- contractRef.withdrawFarmer()

        destroy farmer
    }
}