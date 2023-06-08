import FlowFarm from "../../contracts/FlowFarm.cdc"
import Player from "../../contracts/Player.cdc"

transaction {

    prepare(account: AuthAccount) {

        let farmer <- Player.newFarmer(energy: 10.0)

        let farm <- account.load<@FlowFarm.Farm>(from: /storage/myFarm)!

        farm.field.employ(farmer: <-farmer)

        account.save(<-farm, to: /storage/myFarm)

    }

}