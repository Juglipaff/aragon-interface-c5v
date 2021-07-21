<template>
    <div :class="[holder.isManager ? 'manager' : (holder.isAdmin ? 'admin' : ''), 'holder']">
        <div :class="[holder.isManager ? 'addressViolet' : holder.isAdmin ? 'addressRed' : 'addressBlue','holderAddress']">{{cutAddress(holder.address)}}</div>
        <button v-if="isAdmin" class="holderButton" :disabled="!hasPermission||currentAccount.length===0||!isRightChain||loadingBurn" v-on:click="burn(holder.address)">
            <span v-if="!loadingBurn">Remove</span>
            <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
        </button>
        <button class="demoteButton" v-if="holder.isAdmin && isManager" :disabled="!hasPermission||currentAccount.length===0||!isRightChain||loadingDemote" v-on:click="demote(holder.address)">
            <span v-if="!loadingDemote">Demote to Member</span>
            <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
        </button>
        <button class="promoteButton" v-else-if="isManager" :disabled="!hasPermission||currentAccount.length===0||!isRightChain||loadingDemote" v-on:click="promote(holder.address)">
            <span v-if="!loadingDemote">Promote to Admin</span>
            <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
        </button>
         <div class="role">{{holder.isAdmin?'Admin ':'Member '}}<span>{{holder.isManager?'& Manager':''}}</span></div>
    </div>
</template>

<script>
import { ethers } from 'ethers'
export default {
  name: 'Question',
  props: {
    provider: Object,
    tokensContract: Object,
    ACLContract: Object,
    holder: Object,
    currentAccount: Array,
    hasPermission: Boolean,
    isManager: Boolean,
    isAdmin: Boolean,
    isRightChain: Boolean
  },
  data () {
    return {
      loadingBurn: false,
      loadingDemote: false
    }
  },
  methods: {
    async promote (address) {
      try {
        this.loadingDemote = true
        const tx = await this.ACLContract.connect(this.provider.getSigner()).grantPermission(address, this.tokensContract.address, '0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775')
        await tx.wait()
      } catch (err) {
        console.log(err)
      }// else show error
      this.loadingDemote = false
      this.$emit('update')
    },
    async demote (address) {
      try {
        this.loadingDemote = true
        const tx = await this.ACLContract.connect(this.provider.getSigner()).revokePermission(address, this.tokensContract.address, '0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775')
        await tx.wait()
      } catch (err) {
        console.log(err)
      }// else show error
      this.loadingDemote = false
      this.$emit('update')
    },
    async burn (address) {
      try {
        this.loadingBurn = true
        const tx = await this.tokensContract.connect(this.provider.getSigner()).burn(address, 1)
        await tx.wait()
      } catch (err) {
        console.log(err)
      }// else show error
      this.loadingBurn = false
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
.role{
  border-radius:5px;
  margin-right: 20px;
  float:right;
  background-color:rgba(0, 0, 0,0.05);
  padding-top:5px;
  padding-bottom:5px;
  padding-left:10px;
  padding-right:10px;
}
.manager{
  background-color:rgb(250, 241, 253);
}
.admin{
  background-color:rgb(255, 246, 248);
}
.holder{
  padding-top:20px;
  padding-left: 20px;
  padding-bottom:20px;
  border-bottom:1px solid rgb(228, 228, 228);
}
.promoteButton{
  transition:0.2s;
  outline:none;
  border:none;
  border-radius:5px;
  color:white;
  background-color:rgb(44, 198, 143);
  border:none;
  margin-top:1px;
  margin-right:10px;
  float:right;
  height:30px;
  width:140px;
}
.promoteButton:hover{
   background-color:rgb(38, 168, 123);
}
.promoteButton:disabled{
   cursor: default;
   background-color:rgb(179, 179, 179);
}
.demoteButton{
  transition:0.2s;
  outline:none;
  border:none;
  border-radius:5px;
  color:white;
  background-color:rgb(255, 105, 105);
  border:none;
  margin-top:1px;
  margin-right:10px;
  float:right;
  height:30px;
  width:140px;
}
.demoteButton:hover{
   background-color:rgb(223, 92, 92);
}
.demoteButton:disabled{
   cursor: default;
   background-color:rgb(179, 179, 179);
}
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

  width:fit-content;
  width:160px;
  font-size: 19px;
  text-align: center;
  line-height:30px;
  border-radius: 5px;
}
.addressViolet{
  background-color:rgb(238, 212, 255);
}
.addressRed{
  background-color:rgb(255, 224, 224);
}
.addressBlue{
  background-color:rgb(228, 250, 255);
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
