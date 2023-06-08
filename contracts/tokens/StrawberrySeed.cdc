import FungibleToken from "../standards/FungibleToken.cdc"

pub contract StrawberrySeed: FungibleToken {

    pub var totalSupply: UFix64

    pub let VaultStoragePath: StoragePath
    pub let ReceiverPublicPath: PublicPath

    pub event TokensInitialized(initialSupply: UFix64)
    pub event TokensWithdrawn(amount: UFix64, from: Address?)
    pub event TokensDeposited(amount: UFix64, to: Address?)
    pub event TokensMinted(amount: UFix64)

    pub resource Vault:
        FungibleToken.Provider,
        FungibleToken.Receiver,
        FungibleToken.Balance
    {

        pub var balance: UFix64

        init(balance: UFix64) {
            self.balance = balance
        }

        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            self.balance = self.balance - amount
            emit TokensWithdrawn(amount: amount, from: self.owner?.address)
            return <-create Vault(balance: amount)
        }

        pub fun deposit(from: @FungibleToken.Vault) {
            let vault <- from as! @StrawberrySeed.Vault
            self.balance = self.balance + vault.balance
            emit TokensDeposited(amount: vault.balance, to: self.owner?.address)
            vault.balance = 0.0
            destroy vault
        }

        destroy() {
            if self.balance > 0.0 {
                StrawberrySeed.totalSupply = StrawberrySeed.totalSupply - self.balance
            }
        }

    }

    pub fun createEmptyVault(): @Vault {
        return <-create Vault(balance: 0.0)
    }

    // everyone can mint seeds
    pub fun mintTokens(amount: UFix64): @StrawberrySeed.Vault {
        pre {
            amount > 0.0: "Amount minted must be greater than zero"
        }
        StrawberrySeed.totalSupply = StrawberrySeed.totalSupply + amount
        emit TokensMinted(amount: amount)
        return <-create Vault(balance: amount)
    }

    init() {
        self.totalSupply = 0.0
        self.VaultStoragePath = /storage/strawberrySeedTokenVault
        self.ReceiverPublicPath = /public/strawberrySeedTokenReceiver

        emit TokensInitialized(initialSupply: self.totalSupply)
    }
}
