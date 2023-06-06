import FlowFarm from "../../contracts/FlowFarm.cdc"
import StrawberrySeed from "../../contracts/StrawberrySeed.cdc"

transaction {

    prepare(account: AuthAccount) {

        let farm <- FlowFarm.newFarm()

        let seeds <- StrawberrySeed.mintTokens(amount: 10.0)

        farm.field.plant(seeds: <- seeds)

        account.save(<-farm, to: /storage/myFarm)

    }

}