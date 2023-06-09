import FlowFarm from "../../contracts/FlowFarm.cdc"

transaction {
    prepare(owner: AuthAccount) {

        // create a new Farmer
        let farmer <- FlowFarm.newFarmer(energy: 10.0)

        // load Farm from storage
        let farm <- owner.load<@FlowFarm.Farm>(from: /storage/myFarm)!

        // employ the Farmer
        farm.field.employ(farmer: <-farmer)

        // save the Farm back to storage
        owner.save(<-farm, to: /storage/myFarm)
    }
}