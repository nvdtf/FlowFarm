import FlowFarm from "../../contracts/FlowFarm.cdc"

transaction {
    prepare(account: AuthAccount) {

        // create a new Farmer
        let farmer <- FlowFarm.newFarmer(energy: 10.0)

        // load Farm from storage
        let farm <- account.load<@FlowFarm.Farm>(from: /storage/myFarm)!

        // employ the Farmer
        farm.field.employ(farmer: <-farmer)

        // save the Farm back to storage
        account.save(<-farm, to: /storage/myFarm)
    }
}