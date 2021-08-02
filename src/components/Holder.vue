<template>
    <div :class="addressPrimaryColor" v-if="holder">

        <div :class="addressSecondaryColor">{{cutAddress(holder.holder)}}</div>

        <button v-if="holder.role !== 'Manager'" class="holderButton" :disabled="currentAccount.length===0||!isRightChain||loadingBurn" v-on:click="burn(holder.holder)">
            <span v-if="!loadingBurn">Remove</span>
            <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
        </button>

        <div class="roleManager" v-if="holder.role === 'Manager'">Manager</div>
        <div :class="[holder.role === 'Admin'? 'roleAdmin':(holder.role === 'Expert'?'roleExpert':'roleMember')]" v-else v-on:click="openRoleModal=true">+ {{holder.role === 'Admin'?'Admin':holder.role === 'Expert'?'Expert':'Member'}}</div>

        <button :class="[holder.name ? 'updateName' : 'addName']" v-on:click="openNameModal=true">
            <span v-if="holder.name">{{holder.name}}</span><span v-else>+ Assign Name</span>
        </button>

        <button :class="[holder.position ? 'updatePosition' : 'addPosition']" v-on:click="openPositionModal=true">
            <span v-if="holder.position">{{holder.position}}</span><span v-else>+ Assign Position</span>
        </button>

      <div class="modalDiv">

         <div v-if="openNameModal||openPositionModal||openRoleModal"
          class="closeModalBackground"
          v-on:click="
            openNameModal=false;
            openPositionModal=false;
            openRoleModal=false"></div>

         <div v-if="openNameModal" class="nameModal">
          Change user name <br>
          <input type="text" class="input" v-model="newName">
          <button class="nameButton" :disabled="currentAccount.length===0||!isRightChain||loadingName" v-on:click="assignName(holder.holder,newName)">
              <span v-if="!loadingName">Change</span>
              <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
          </button>
        </div>

      <div class="positionDiv">
        <div v-if="openPositionModal" class="positionModal">
          Change user position <br>
          <input type="text" class="input" v-model="newPosition">
          <button class="nameButton" :disabled="currentAccount.length===0||!isRightChain||loadingPosition" v-on:click="assignPosition(holder.holder,newPosition)">
              <span v-if="!loadingPosition">Change</span>
              <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
          </button>
        </div>
      </div>

      <div class="roleDiv">
        <div v-if="openRoleModal" class="roleModal">
          Change user role <br>
          <button v-if="holder.role !== 'Admin' || holder.role === 'Expert'" class="adminButton" :disabled="currentAccount.length===0||!isRightChain||loadingDemote" v-on:click="setAdmin(holder.holder)">
            <span v-if="!loadingDemote">Admin</span>
            <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
          </button>

          <button v-if="holder.role === 'Admin' || holder.role === 'Expert'" class="memberButton" :disabled="currentAccount.length===0||!isRightChain||loadingDemote" v-on:click="demote(holder.holder)">
            <span v-if="!loadingDemote">Member</span>
            <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
          </button>

          <button  v-if="holder.role === 'Admin' || holder.role !== 'Expert'" class="expertButton" :disabled="currentAccount.length===0||!isRightChain||loadingDemote" v-on:click="setExpert(holder.holder)">
            <span v-if="!loadingDemote">Expert</span>
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
    isRightChain: Boolean
  },
  data () {
    return {
      loadingBurn: false,
      loadingDemote: false,
      loadingName: false,
      loadingPosition: false,
      openRoleModal: false,
      openNameModal: false,
      newName: '',
      openPositionModal: false,
      newPosition: ''
    }
  },

  computed: {
    addressPrimaryColor () {
      if (this.holder.role === 'Manager') {
        return ['manager', 'holder2']
      }
      if (this.holder.role === 'Admin') {
        return ['admin', 'holder2']
      }
      if (this.holder.role === 'Expert') {
        return ['expert', 'holder2']
      }
      return 'holder2'
    },
    addressSecondaryColor () {
      if (this.holder.role === 'Manager') {
        return ['addressViolet', 'holderAddress']
      }
      if (this.holder.role === 'Admin') {
        return ['addressRed', 'holderAddress']
      }
      if (this.holder.role === 'Expert') {
        return ['addressGreen', 'holderAddress']
      }
      return ['addressBlue', 'holderAddress']
    }
  },
  created () {
    console.log(this.holder)
  },
  methods: {
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
          this.$emit('error', 'The transaction was rejected.')
        }
        this.$emit('update')
      } else {
        this.$emit('error', 'Please enter a position.')
      }
      this.loadingPosition = false
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
          this.$emit('error', 'The transaction was rejected.')
        }
        this.$emit('update')
      } else {
        this.$emit('error', 'Please enter a name.')
      }
      this.loadingName = false
    },
    async setExpert (address) {
      try {
        this.loadingDemote = true
        const tx = await this.managerContract.connect(this.provider.getSigner()).addExpert(
          address,
          {
            gasPrice: '0'
          }
        )
        await tx.wait()
      } catch (err) {
        console.log(err)
        this.$emit('error', 'The transaction was rejected.')
      }
      this.loadingDemote = false
      this.$emit('update')
    },
    async setAdmin (address) {
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
        this.$emit('error', 'The transaction was rejected.')
      }
      this.loadingDemote = false
      this.$emit('update')
    },
    async demote (address) { // doesnt work if the user is admin
      try {
        this.loadingDemote = true
        const tx = await this.managerContract.connect(this.provider.getSigner()).addMember(
          address,
          {
            gasPrice: '0'
          }
        )
        await tx.wait()
      } catch (err) {
        console.log(err)
        this.$emit('error', 'The transaction was rejected.')
      }
      this.loadingDemote = false
      this.$emit('update')
    },
    async burn (address) {
      try {
        this.loadingBurn = true
        const tx = await this.managerContract.connect(this.provider.getSigner()).burn(
          address,
          {
            gasPrice: '0'
          }
        )
        await tx.wait()
      } catch (err) {
        console.log(err)
        this.$emit('error', 'The transaction was rejected.')
      }
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
.expertButton{
   margin-top:5px;
  vertical-align: top;
  transition:0.2s;
  border-radius:3px;
  margin-left:10px;
  cursor: pointer;
  height:30px;
  background-color:rgb(87, 209, 107);
  color:white;
  border:none;
  width:100px;
  font-size:16px;
}
.expertButton:hover{
 background-color:rgb(89, 187, 76);
}
.memberButton{
  margin-top:5px;
  vertical-align: top;
  transition:0.2s;
  border-radius:3px;
  margin-left:10px;
  cursor: pointer;
  height:30px;
  background-color:rgb(121, 174, 255);
  color:white;
  border:none;
  width:100px;
  font-size:16px;
}
.memberButton:hover{
 background-color:rgb(96, 145, 218);
}
.adminButton{
      margin-top:5px;
  vertical-align: top;
  transition:0.2s;
   border-radius:3px;
   margin-left:10px;
  cursor: pointer;
  height:30px;
 background-color:rgb(255, 105, 105);
 color:white;
 border:none;
 width:100px;
 font-size:16px;
}
.adminButton:hover{
 background-color:rgb(218, 80, 80);
}

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
.roleDiv{
  position:relative;
  float:right;
  right:220px;

}
.roleModal{
   margin-top:7px;
  position: absolute;
  padding-top:8px;
  padding-bottom:10px;
  padding-right:7px;
  padding-left:7px;
  background-color:white;
  border:1px solid rgb(228, 228, 228);
  border-radius:10px;
  z-index:1000;
  width:230px;
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
cursor: pointer;
height:26px;
 background-color:rgb(105, 175, 255);
 color:white;
 border:none;
 width:60px;
}
.nameButton:hover{
 background-color:rgb(75, 159, 255);
}
.nameButton:disabled{
 background-color:rgb(179, 179, 179);
}
.roleAdmin{
  cursor: pointer;
  border-radius:5px;
  margin-right: 20px;
  float:right;
  color:rgb(255, 105, 105);
  border:2px solid rgb(255, 105, 105);
  padding-top:4px;
  padding-bottom:3px;
  padding-left:10px;
  margin-top:2px;
  padding-right:10px;
}
.roleAdmin:hover{
  background-color:rgba(0, 0, 0,0.03);
}
.roleManager{
  border-radius:5px;
  margin-right: 20px;
  float:right;
  background-color:rgba(0, 0, 0,0.06);
  padding-top:5px;
  padding-bottom:5px;
  padding-left:10px;
  padding-right:10px;
}
.roleMember{
  cursor: pointer;
  border-radius:5px;
  margin-right: 20px;
  float:right;
  color:rgb(105, 175, 255);
  border:2px solid rgb(105, 175, 255);
  padding-top:4px;
  padding-bottom:3px;
  padding-left:10px;
  margin-top:2px;
  padding-right:10px;
}
.roleMember:hover{
  background-color:rgba(0, 0, 0,0.03);
}
.roleExpert{
  cursor: pointer;
  border-radius:5px;
  margin-right: 20px;
  float:right;
  color:rgb(44, 168, 71);
  border:2px solid rgb(44, 168, 71);
  padding-top:4px;
  padding-bottom:3px;
  padding-left:10px;
  margin-top:2px;
  padding-right:10px;
}
.roleExpert:hover{
  background-color:rgba(0, 0, 0,0.03);
}
.manager{
  background-color:rgb(250, 241, 253);
}
.admin{
  background-color:rgb(255, 246, 248);
}
.expert{
  background-color:rgb(246, 255, 247);
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
.addressGreen{
  background-color:rgb(212, 255, 215);
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
