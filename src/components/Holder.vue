<template>
    <div>
        <div class="holderAddress">{{cutAddress(holder)}}</div>
        <button class="holderButton" :disabled="!hasPermission||currentAccount.length===0||!isRightChain||loading" v-on:click="burn(holder)">
            <span v-if="!loading">Remove</span>
            <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
        </button>
    </div>
</template>

<script>
import { ethers } from 'ethers'
export default {
  name: 'Question',
  props: {
    provider: Object,
    tokenAddress: String,
    holder: String,
    currentAccount: Array,
    hasPermission: Boolean,
    isRightChain: Boolean
  },
  data () {
    return {
      loading: false
    }
  },
  methods: {
    async burn (address) {
      this.loading = true
      const intent = this.organisation.appIntent(this.tokenAddress, 'burn', [address, 1])
      try {
        const transactions = await intent.transactions(this.currentAccount[0])
        const tx = await this.provider.send('eth_sendTransaction', transactions)
        var transactionResult = await this.provider.getTransaction(tx)
        await transactionResult.wait()
      } catch (err) {
        console.log(err)
      }
      this.loading = false
      this.$emit('update')
    },
    cutAddress (address) {
      address = ethers.utils.getAddress(address)
      return address.substring(0, 6) + '...' + address.substring(address.length - 4, address.length)
    }
  }
}
</script>
<style scoped>
.holderButton{
  transition:0.2s;
  outline:none;
  border:none;
  border-radius:5px;
  color:white;
  background-color:rgb(255, 105, 105);
  border:none;
  margin-top:1px;
  margin-right:20px;
  float:right;
  height:30px;
  width:70px;
}
.holderButton:hover{
   background-color:rgb(223, 92, 92);
}
.holderButton:disabled{
   cursor: default;
   background-color:rgb(179, 179, 179);
}
.holderAddress{
  display:inline-block;
  height:30px;
  background-color:rgb(228, 250, 255);
  width:fit-content;
  width:160px;
  font-size: 19px;
  text-align: center;
  line-height:30px;
  border-radius: 5px;
}
.lds-ellipsis {
  display: inline-block;
  position: absolute;
  margin-top:-39px;
  margin-left:-36px;
  width: 80px;
  height: 80px;
}
.lds-ellipsis div {
  position: absolute;
  top: 33px;
  width: 11px;
  height: 11px;
  border-radius: 50%;
  background: #fff;
  animation-timing-function: cubic-bezier(0, 1, 1, 0);
}
.lds-ellipsis div:nth-child(1) {
  left: 8px;
  animation: lds-ellipsis1 0.6s infinite;
}
.lds-ellipsis div:nth-child(2) {
  left: 8px;
  animation: lds-ellipsis2 0.6s infinite;
}
.lds-ellipsis div:nth-child(3) {
  left: 32px;
  animation: lds-ellipsis2 0.6s infinite;
}
.lds-ellipsis div:nth-child(4) {
  left: 56px;
  animation: lds-ellipsis3 0.6s infinite;
}
@keyframes lds-ellipsis1 {
  0% {
    transform: scale(0);
  }
  100% {
    transform: scale(1);
  }
}
@keyframes lds-ellipsis3 {
  0% {
    transform: scale(1);
  }
  100% {
    transform: scale(0);
  }
}
@keyframes lds-ellipsis2 {
  0% {
    transform: translate(0, 0);
  }
  100% {
    transform: translate(24px, 0);
  }
}
</style>
