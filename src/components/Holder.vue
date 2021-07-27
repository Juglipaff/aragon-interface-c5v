<template>
    <div :class="[holder.isManager ? 'manager' : (holder.isAdmin ? 'admin' : ''), 'holder2']">
        <div :class="[holder.isManager ? 'addressViolet' : holder.isAdmin ? 'addressRed' : 'addressBlue','holderAddress']">{{cutAddress(holder.holder)}}</div>
        <button v-if="isAdmin&&!holder.isManager" class="holderButton" :disabled="!hasPermission||currentAccount.length===0||!isRightChain||loadingBurn" v-on:click="burn(holder.holder)">
            <span v-if="!loadingBurn">Remove</span>
            <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
        </button>
        <button class="demoteButton" v-if="holder.isAdmin &&!holder.isManager" :disabled="currentAccount.length===0||!isRightChain||loadingDemote" v-on:click="demote(holder.holder)">
            <span v-if="!loadingDemote">Demote to Member</span>
            <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
        </button>
        <button class="promoteButton" v-else-if="!holder.isManager" :disabled="currentAccount.length===0||!isRightChain||loadingDemote" v-on:click="promote(holder.holder)">
            <span v-if="!loadingDemote">Promote to Admin</span>
            <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
        </button>
        <div class="role">{{holder.isAdmin?'Admin ':'Member '}}<span>{{holder.isManager?' Manager':''}}</span></div>

        <button v-if="isAdmin" :class="[holder.name ? 'updateName' : 'addName']" v-on:click="openName()">
            <span v-if="holder.name">{{holder.name}}</span><span v-else>+ Add Name</span>
        </button>

        <button v-if="isAdmin" :class="[holder.position ? 'updatePosition' : 'addPosition']" v-on:click="openPosition()">
            <span v-if="holder.position">{{holder.position}}</span><span v-else>+ Add Position</span>
        </button>

      <div class="modalDiv" v-if="isAdmin">
         <div v-if="openNameModal||openPositionModal" class="closeModalBackground" v-on:click="openNameModal=false; openPositionModal=false;"></div>
         <div v-if="openNameModal" class="nameModal">
          Change user name: <br>
          <input type="text" class="input" v-model="newName">
          <button class="nameButton" :disabled="!hasPermission||currentAccount.length===0||!isRightChain||loadingName" v-on:click="assignName(holder.holder,newName)">
              <span v-if="!loadingName">Change</span>
              <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
          </button>
        </div>

      <div class="positionDiv"  v-if="isAdmin">
        <div v-if="openPositionModal" class="positionModal">
          Change user position: <br>
          <input type="text" class="input" v-model="newPosition">
          <button class="nameButton" :disabled="!hasPermission||currentAccount.length===0||!isRightChain||loadingPosition" v-on:click="assignPosition(holder.holder,newPosition)">
              <span v-if="!loadingPosition">Change</span>
              <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
          </button>
        </div>
        </div>
    </div>
    </div>
</template>

<script>
import { ethers } from 'ethers'
export default {
  name: 'Question',
  props: {
    provider: Object,
    managerContract: Object,
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
      loadingDemote: false,
      loadingName: false,
      loadingPosition: false,
      openNameModal: false,
      newName: '',
      openPositionModal: false,
      newPosition: ''
    }
  },
  methods: {
    openPosition () {
      this.openPositionModal = true
    },
    openName () {
      this.openNameModal = true
    },
    async assignPosition (address, position) {
      if (position !== '') {
        try {
          this.loadingPosition = true
          const tx = await this.managerContract.connect(this.provider.getSigner()).assignPosition(
            address,
            position,
            {
              gasPrice: '0'
            }
          )
          await tx.wait()
        } catch (err) {
          console.log(err)
        }// else show error
        this.loadingPosition = false
        this.$emit('update')
      }
    },
    async assignName (address, name) {
      if (name !== '') {
        try {
          this.loadingName = true
          const tx = await this.managerContract.connect(this.provider.getSigner()).assignName(
            address,
            name,
            {
              gasPrice: '0'
            }
          )
          await tx.wait()
        } catch (err) {
          console.log(err)
        }// else show error
        this.loadingName = false
        this.$emit('update')
      }
    },
    async promote (address) {
      try {
        this.loadingDemote = true
        const tx = await this.managerContract.connect(this.provider.getSigner()).addAdmin(
          address,
          {
            gasPrice: '0'
          }
        )
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
        const tx = await this.managerContract.connect(this.provider.getSigner()).removeAdmin(
          address,
          {
            gasPrice: '0'
          }
        )
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
        const tx = await this.managerContract.connect(this.provider.getSigner()).burn(
          address,
          1,
          {
            gasPrice: '0'
          }
        )
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
.closeModalBackground{
  position: fixed;
  width:100vw;
  height:100vh;
  top:0;
  right:0;
  left:0;
  bottom:0;
  z-index:999;
}
.modalDiv{
  margin-left:80px;
}
.positionDiv{
  margin-left:90px;
}
.positionModal{
  margin-top:7px;
  position: absolute;
  padding-top:8px;
  padding-bottom:15px;
  padding-right:15px;
  padding-left:15px;
  background-color:white;
  border:1px solid rgb(228, 228, 228);
  border-radius:10px;
  z-index:1000;
}
.nameModal{
    margin-top:7px;
  position: absolute;
  padding-top:8px;
  padding-bottom:15px;
  padding-right:15px;
  padding-left:15px;
  background-color:white;
  border:1px solid rgb(228, 228, 228);
  border-radius:10px;
  z-index:1000;
}
.input{
  margin-top:5px;
 border:2px solid rgb(105, 175, 255);
 height:20px;
 border-radius:3px;
}
.nameButton{
     margin-top:5px;
  vertical-align: top;
  transition:0.2s;
   border-radius:3px;
   margin-left:3px;

height:26px;
 background-color:rgb(105, 175, 255);
 color:white;
 border:none;
 width:60px;
}
.nameButton:hover{
 background-color:rgb(75, 159, 255);
}
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
.holder2{
  padding-top:10px;
  padding-left: 20px;
  padding-bottom:10px;
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
.updatePosition{
  transition:0.2s;
  outline:none;
  border:none;
  border-radius:5px;
  color:white;
  background-color:rgb(188, 105, 255);
  border:2px solid rgb(188, 105, 255);
  margin-top:1px;
  margin-left:10px;
  height:30px;
  padding-left:7px;
  padding-right:7px;
}
.updatePosition:hover{
  background-color:rgb(173, 73, 255);
  border:2px solid rgb(173, 73, 255);
}

.addPosition{
  transition:0.2s;
  outline:none;
  border:none;
  border-radius:5px;
  color:rgb(188, 105, 255);
  background-color:white;
  border:2px solid rgb(188, 105, 255);
  margin-top:1px;
  margin-left:10px;
  height:30px;
  padding-left:7px;
  padding-right:7px;
}
.addPosition:hover{
 background-color:rgb(236, 236, 236);
}

.updateName{
  transition:0.2s;
  outline:none;
  border:none;
  border-radius:5px;
  color:white;
  background-color:rgb(105, 175, 255);
  border:2px solid rgb(105, 175, 255);
  margin-top:1px;
  margin-left:10px;
  height:30px;
  padding-left:7px;
  padding-right:7px;
}
.updateName:hover{
  background-color:rgb(72, 157, 255);
  border:2px solid rgb(72, 157, 255);
}
.addName{
  transition:0.2s;
  outline:none;
  border:none;
  border-radius:5px;
  color:rgb(105, 175, 255);
  background-color:white;
  border:2px solid rgb(105, 175, 255);
  margin-top:1px;
  margin-left:10px;
  height:30px;
  padding-left:7px;
  padding-right:7px;
}
.addName:hover{
 background-color:rgb(236, 236, 236);
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
