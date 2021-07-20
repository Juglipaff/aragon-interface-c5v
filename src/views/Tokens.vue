<template>
  <div class="home" v-if="token">
      <div>
        Total supply {{token.totalSupply}}
      </div>
      <div>
        Transferable {{token.transferable}}
      </div>
      <div>
        Token {{token.name}}({{token.symbol}})
      </div>
    <div v-for="holder in holders" :key="holder.address" class="question">
        {{holder.address}}
        {{holder.balance}}
        <button v-on:click="burn(holder.address)">Remove token</button>
    </div>
    <input v-model="mintAddress">
    <button v-on:click="mint(mintAddress)">Add token</button>
  </div>
</template>

<script>
import connect from '@aragon/connect'
import connectTokens from '@aragon/connect-tokens'
import { ethers } from 'ethers'

export default {
  name: 'Tokens',
  data () {
    return {
      chainId: 4,
      currentAccount: [],
      provider: null,
      organisation: null,
      tokens: null,
      token: null,
      holders: [],
      mintAddress: ''
    }
  },
  async created () {
    if (window.ethereum) {
      window.ethereum.on('chainChanged', (chain) => {
        this.rightChainId = parseInt(chain) === parseInt(this.chainId)
      })
      window.ethereum.on('accountsChanged', (accounts) => {
        this.currentAccount = accounts
      })
      this.provider = new ethers.providers.Web3Provider(window.ethereum)
      const providerChainId = (await this.provider.getNetwork()).chainId
      this.rightChainId = providerChainId === this.chainId // use it

      if (!this.rightChainId) {
        this.provider = new ethers.providers.JsonRpcProvider('https://rinkeby.infura.io/v3/9e1ee70bb94b493eb5d2f65592d464cd')
      }
      var address = window.ethereum.selectedAddress
      if (address !== null) {
        this.currentAccount = [address]
      }
    } else {
      this.provider = new ethers.providers.JsonRpcProvider('https://rinkeby.infura.io/v3/9e1ee70bb94b493eb5d2f65592d464cd')
    }
    this.organisation = await connect('juglipaff.aragonid.eth', 'thegraph', { network: this.chainId })
    this.tokens = await connectTokens(this.organisation.app('token-manager'))
    this.token = await this.tokens.token()
    this.holders = await this.tokens.holders()
  },
  methods: {
    async burn (from) {
      const intent = this.organisation.appIntent(this.tokens.address, 'burn', [from, 1])
      await this.waitForTransaction(intent)
    },
    async mint (to) {
      if (ethers.utils.isAddress(to)) {
        const intent = this.organisation.appIntent(this.tokens.address, 'mint', [to, 1])
        await this.waitForTransaction(intent)
      }
    },
    async waitForTransaction (intent) {
      const transactions = await intent.transactions(this.currentAccount[0])
      const tx = await this.provider.send('eth_sendTransaction', transactions)
      const transactionResult = await this.provider.getTransaction(tx)
      await transactionResult.wait()
      this.tokens = await connectTokens(this.organisation.app('token-manager'))
      this.holders = await this.tokens.holders()
      return transactionResult
    }
  }
}
</script>
<style scoped>

.question{
  padding-top:15px;
  padding-bottom:15px;
  max-width:700px;
  margin:0 auto;
  margin-bottom:15px;
  background-color:white;
  border:1px solid rgb(228, 228, 228);
  border-radius:10px;
}
</style>
