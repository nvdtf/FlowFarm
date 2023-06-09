import FlowFarm from "../../contracts/FlowFarm.cdc"
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
    }
}