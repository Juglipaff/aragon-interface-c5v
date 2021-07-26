<template>
  <div class="home">
    <transition name="fade">
       <div key="1" v-if="pageLoading===false" class="container">

         <div class="voteSettings" v-if="showSettingsModal">
           <div class="voteSettingsBG" v-on:click="showSettings"></div>
            <div class="settingsContainer">
              <div class="settingsHolder">
                <div class="requirements">Minimum Support</div>
                  <button v-on:click="changeSupport(supportRequiredPct)" class="holderButton" :disabled="!hasPermission||currentAccount.length===0||loadingSupport||!rightChainId">
                    <span v-if="!loadingSupport">Propose Change</span>
                    <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
                  </button>
                <input type="number" class="settingValue" v-model="supportRequiredPct">
              </div>
              <div class="settingsHolder">
                <div class="requirements">Minimum Approval</div>
                  <button v-on:click="changeMinQuorum(minAcceptQuorum)" class="holderButton" :disabled="!hasPermission||currentAccount.length===0||loadingQuorum||!rightChainId">
                    <span v-if="!loadingQuorum">Propose Change</span>
                    <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
                  </button>
                <input type="number" class="settingValue" v-model="minAcceptQuorum">
              </div>
            </div>
         </div>

        <div class="header">
            <font-awesome-icon class="cog" v-if="hasPermission" v-on:click="showSettings" :icon="['fas', 'cog']" />
            <div v-if="!rightChainId" class="wrongNet" v-on:click="switchNetwork">Wrong Network!</div>
            <button v-else-if="currentAccount.length===0" class="connectWallet" v-on:click="connectWallet">Connect wallet</button>
            <div v-else class="wallet">{{currentAccount[0]}}</div>
            <div v-if="userName||userPosition" class="NamePosition">{{userName}}{{userPosition&&userName?' | ':''}}{{userPosition}}</div>

            <div v-if="isManager" class="role">{{hasPermission? 'Admin':''}} Manager</div>
            <div v-else-if="isAdmin" class="role">Admin</div>
            <div v-else-if="hasPermission" class="role">Member</div>
            <div v-else class="role">Guest</div>

        </div>
        <div class="padding"></div>
        <div v-if="hasPermission" class="createVote">Create Proposal</div>
          <div v-if="hasPermission" class="top-row">
            <div class="questionInput">
              <div class="question-title">Question</div>
              <input class="inputQuestion" v-model="question">
              <button class="submit" :disabled="!hasPermission||question===''||currentAccount.length===0 ||loadingCreate||!rightChainId" v-on:click="createVote(question)">
                <span v-if="!loadingCreate">Create Proposal</span>
                <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
              </button>
            </div>
            <div class="tokenInfo">
              <div class="tokenInfoHeader">Token Info</div>
              <div class="infoToken">
                Total supply<br>
                Transferable<br>
                Token
              </div>
              <div class="infoToken2">
                {{token.totalSupply}} <br>
                {{token.transferable?'YES':'NO'}}
                <div class="tokenName">{{token.name}}({{token.symbol}})</div>
              </div>
            </div>
          </div>
          <div class="createVote">Open Proposals - {{openVotes.length}}</div>
          <div class="wrapper">
            <QUESTION
              v-for="entry in openVotes"
              :key="entry.id"
              @update="update"
              :tokenSymbol="token.symbol"
              :votingContract="votingContract"
              :question="entry"
              :votingAddress="votingAddress"
              :currentAccount="currentAccount[0]"
              :provider="provider"
              :hasPermission="hasPermission"
              :updateList="updateList"
              :isRightChain="rightChainId"
              />
            </div>

          <div  v-if="isAdmin" class="createVote">Token Holders</div>
            <div v-if="isAdmin" class="tokenHolders">
              <div class="holderHeader">Holder</div>
              <HOLDER
              v-for="holder in holders"
              :key="holder.address"
              @update="update"
              :isManager="isManager"
              :isAdmin="isAdmin"
              :ACLContract="ACLContract"
              :provider="provider"
              :tokensContract="tokensContract"
              :holder="holder"
              :currentAccount="currentAccount"
              :hasPermission="hasPermission"
              :isRightChain="rightChainId"
              />
              <div class="holder" v-if="isAdmin">
                <input class="inputHolder" placeholder="Address" v-model="newAddress">
                <button class="submitHolder" :disabled="!hasPermission||newAddress===''||currentAccount.length===0||loadingMint||!rightChainId" v-on:click="mint(newAddress)">
                  <span v-if="!loadingMint">Add Participant</span>
                  <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
                </button>
              </div>
            </div>

            <!-- <div v-if="hasPermission" class="createVote">Vote Settings</div> -->
            <div v-if="hasPermission" class="tokenHolders">

            </div>

          <div class="createVote">Closed Proposals - {{closedVotes.length}}</div>
            <div class="wrapper">
              <QUESTION
                v-for="entry in closedVotes"
                :key="entry.id"
                @update="update"
                :tokenSymbol="token.symbol"
                :votingContract="votingContract"
                :question="entry"
                :votingAddress="votingAddress"
                :currentAccount="currentAccount[0]"
                :provider="provider"
                :hasPermission="hasPermission"
                :updateList="updateList"
                :isRightChain="rightChainId"
                />
            </div>
        </div>
     <div key="2" v-else class="loading-status">
        <div class="loading-text"><div class="lds-default"><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div><div class="text"></div></div>
    </div>
    </transition>
  </div>
</template>

<script>
import { ethers } from 'ethers'
import Question from '../components/Question.vue'
import Holder from '../components/Holder.vue'
import votingABI from '../voting.json'
import tokensABI from '../tokens.json'
import tokenABI from '../miniMe.json'
import aclABI from '../acl.json'
import { encodeCallScript } from '@aragon/connect-core'

export default {
  name: 'Voting',
  components: {
    QUESTION: Question,
    HOLDER: Holder
  },
  data () {
    return {
      chainId: 304,
      currentAccount: [],
      rpcUrl: 'https://rpc.c5v.network/',

      votingAddress: '0xb88797d333af0bd6cd97c2eb6fae562fe1135b25',
      tokensAddress: '0x02fc711a917320f6e598e41704827c94d7f5f83a',
      tokenAddress: '0x8de36eda596c8b615435fccedade18408b798980',
      ACLAddress: '0xb6a1025f9f95fb8090d91cd0c2742a73be903d6b',

      provider: null,
      voting: null,
      votes: [],
      question: '',
      tokens: null,
      token: {},
      openVotes: [],
      closedVotes: [],
      loadingCreate: false,
      loadingMint: false,
      loadingSupport: false,
      loadingQuorum: false,
      pageLoading: true,
      hasPermission: false,
      updateList: false,
      holders: [],
      newAddress: '',
      minAcceptQuorum: 0,
      supportRequiredPct: 0,
      votingContract: null,
      tokensContract: null,
      tokenContract: null,
      ACLContract: null,
      rightChainId: false,
      isAdmin: false,
      manager: false,
      userName: null,
      userPosition: null,
      showSettingsModal: false
    }
  },
  computed: {
    isManager () {
      if (this.currentAccount[0]) {
        return this.manager === ethers.utils.getAddress(this.currentAccount[0])
      }
      return false
    }
  },
  async created () {
    if (window.ethereum) {
      window.ethereum.on('chainChanged', (chain) => {
        this.rightChainId = parseInt(chain) === parseInt(this.chainId)
        location.reload()
      })
      window.ethereum.on('accountsChanged', (accounts) => {
        this.loadingCreate = false
        this.loadingMint = false
        this.loadingSupport = false
        this.loadingQuorum = false
        this.currentAccount = accounts
        this.update()
      })
      this.provider = new ethers.providers.Web3Provider(window.ethereum)
      const providerChainId = (await this.provider.getNetwork()).chainId
      this.rightChainId = providerChainId === this.chainId

      if (!this.rightChainId) {
        this.provider = new ethers.providers.JsonRpcProvider(this.rpcUrl)
      }
      var address = window.ethereum.selectedAddress
      if (address !== null) {
        this.currentAccount = [address]
      }
    } else {
      this.provider = new ethers.providers.JsonRpcProvider(this.rpcUrl)
    }
    this.votingContract = new ethers.Contract(this.votingAddress, votingABI, this.provider)
    this.tokensContract = new ethers.Contract(this.tokensAddress, tokensABI, this.provider)
    this.tokenContract = new ethers.Contract(this.tokenAddress, tokenABI, this.provider)
    this.ACLContract = new ethers.Contract(this.ACLAddress, aclABI, this.provider)

    this.token.name = await this.tokenContract.name()
    this.token.symbol = await this.tokenContract.symbol()
    this.token.transferable = await this.tokenContract.transfersEnabled()
    await this.update()
    this.pageLoading = false
  },

  methods: {
    showSettings () {
      this.showSettingsModal = !this.showSettingsModal
    },
    switchNetwork () {
      if (window.ethereum) {
        window.ethereum.request({
          method: 'wallet_addEthereumChain',
          params: [
            {
              chainId: '0x' + this.chainId.toString(16),
              chainName: 'C5V',
              nativeCurrency: {
                name: 'C5V',
                symbol: 'C5V',
                decimals: 18
              },
              rpcUrls: [this.rpcUrl],
              blockExplorerUrls: ['https://stats.c5v.network/']
            }
          ]
        })
      }
    },

    connectWallet () {
      if (window.ethereum) {
        window.ethereum.request({ method: 'eth_requestAccounts' })
          .catch((err) => { console.log(err) })
      }
    },

    async createVote (question) {
      try {
        if (question !== '') {
          this.loadingCreate = true
          const iface = new ethers.utils.Interface(votingABI)
          const encodedData = iface.encodeFunctionData('newVote', ['0x00000001', question])
          const script = encodeCallScript([{ to: this.votingAddress, data: encodedData }])
          const tx = await this.tokensContract.connect(this.provider.getSigner()).forward(
            script,
            {
              gasPrice: '0'
            }
          )
          await this.waitForTransaction(tx)
        }
      } catch (err) {
        console.log(err)
      }
      this.question = ''
      this.loadingCreate = false
    },

    async mint (to) {
      try {
        if (ethers.utils.isAddress(to)) {
          this.loadingMint = true
          const tx = await this.tokensContract.connect(this.provider.getSigner()).mint(
            to,
            1,
            {
              gasPrice: '0'
            }
          )
          await this.waitForTransaction(tx)
        }
      } catch (err) {
        console.log(err)
      }// else show error
      this.loadingMint = false
      this.newAddress = ''
    },

    async changeMinQuorum (value) {
      try {
        this.loadingQuorum = true
        if (value && value >= 0 && value <= 100) {
          value = ethers.utils.parseEther((value / 100).toString())
          const iface = new ethers.utils.Interface(votingABI)
          const encodedData = iface.encodeFunctionData('changeMinAcceptQuorumPct', [value])
          const script = encodeCallScript([{ to: this.votingAddress, data: encodedData }])

          const encodedDataForwardCall = iface.encodeFunctionData('forward', [script])
          const scriptForwardCall = encodeCallScript([{ to: this.votingAddress, data: encodedDataForwardCall }])
          const tx = await this.tokensContract.connect(this.provider.getSigner()).forward(
            scriptForwardCall,
            {
              gasPrice: '0'
            }
          )
          await this.waitForTransaction(tx)
        }
      } catch (err) {
        console.log(err)
      }
      this.loadingQuorum = false
    },

    async changeSupport (value) {
      try {
        this.loadingSupport = true
        if (value && value >= 0 && value <= 100) {
          value = ethers.utils.parseEther((value / 100).toString())

          const iface = new ethers.utils.Interface(votingABI)
          const encodedData = iface.encodeFunctionData('changeSupportRequiredPct', [value])
          const script = encodeCallScript([{ to: this.votingAddress, data: encodedData }])

          const encodedDataForwardCall = iface.encodeFunctionData('forward', [script])
          const scriptForwardCall = encodeCallScript([{ to: this.votingAddress, data: encodedDataForwardCall }])
          const tx = await this.tokensContract.connect(this.provider.getSigner()).forward(
            scriptForwardCall,
            {
              gasPrice: '0'
            }
          )
          await this.waitForTransaction(tx)
          // const intent = this.organisation.appIntent(this.voting.address, 'changeSupportRequiredPct', [value])
          // await this.waitForTransaction(intent)
        }
      } catch (err) {
        console.log(err)
      }
      this.loadingSupport = false
    },

    async waitForTransaction (transaction) {
      try {
        var tx = await transaction.wait()
      } catch (err) {
        console.log(err)
      }
      await this.update()
      return tx
    },

    async update () {
      try {
        this.manager = await this.ACLContract.getPermissionManager(this.tokensAddress, '0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775')
        const tokenHolders = await this.tokenContract.getTokenHolders()
        const adminList = await this.ACLContract.getAdmins()
        console.log(tokenHolders)
        this.holders = tokenHolders.map((item) => ({
          ...item,
          isAdmin: adminList.includes(item.holder),
          isManager: item.holder.toLowerCase() === this.manager.toLowerCase(),
          hasPermission: true
        }))

        if (!this.holders.find((a) => a.holder === this.manager)) {
          this.holders.push({
            holder: this.manager,
            name: '',
            position: '',
            isAdmin: adminList.includes(this.manager),
            isManager: true,
            hasPermission: false
          })
        }

        this.holders = this.holders.sort((a, b) => {
          if (a.isManager) {
            return -1
          }
          if (a.isAdmin && !b.isAdmin) {
            return -1
          }
          if (a.isAdmin && b.isAdmin) {
            return 0
          }
          if (!a.isAdmin && b.isAdmin) {
            return 1
          }
          if (!a.isAdmin && !b.isAdmin) {
            return 0
          }
          return 1
        })

        if (this.currentAccount[0]) {
          var accountInfo = tokenHolders.find((a) => { return a.holder.toLowerCase() === this.currentAccount[0].toLowerCase() })
          this.hasPermission = !!accountInfo
          this.isAdmin = adminList.includes(ethers.utils.getAddress(this.currentAccount[0]))
        } else {
          this.hasPermission = false
          this.isAdmin = false
        }

        if (this.hasPermission) {
          this.userName = accountInfo.name
          this.userPosition = accountInfo.position
        } else {
          this.userName = null
          this.userPosition = null
        }

        this.token.totalSupply = await this.tokenContract.totalSupply()
        this.minAcceptQuorum = parseInt(ethers.utils.formatEther(await this.votingContract.minAcceptQuorumPct()) * 100)
        this.supportRequiredPct = parseInt(ethers.utils.formatEther(await this.votingContract.supportRequiredPct()) * 100)

        const votesLength = await this.votingContract.votesLength()
        this.votes = []
        for (let i = 0; i < votesLength; i++) {
          this.votes.push(await this.votingContract.getVote(i))
        }
        this.votes = this.votes.map((item, index) => ({
          ...item,
          id: index
        }))

        this.votes = this.votes.sort((a, b) => {
          return a.startDate > b.startDate ? -1 : 1
        })
        this.openVotes = this.votes.filter((a) => {
          return a.executed === false && a.startDate - Math.floor(Date.now() / 1000) + 86400 > 0
        })
        this.closedVotes = this.votes.filter((a) => {
          return a.executed === true || a.startDate - Math.floor(Date.now() / 1000) + 86400 < 0
        })
        this.updateList = !this.updateList
      } catch (err) {
        console.log(err)
      }
      return true
    }
  }
}
</script>
<style scoped>
.settingsHolder{
  text-align: left;
  padding-top:20px;
  padding-left: 20px;
  padding-bottom:20px;
  border-bottom:1px solid rgb(228, 228, 228);
}
.settingsContainer{
  z-index:1002;
  position: absolute;
  background-color:white;
  right:25px;
  top:75px;
  width:420px;
  border:1px solid rgb(228, 228, 228);
  border-bottom:0px;
  -webkit-box-shadow: -1px 4px 22px 0px rgba(34, 60, 80, 0.11);
  -moz-box-shadow: -1px 4px 22px 0px rgba(34, 60, 80, 0.11);
  box-shadow: -1px 4px 22px 0px rgba(34, 60, 80, 0.11);
}
.voteSettingsBG{
  position: fixed;
  width:100vw;
  height:100vh;
  z-index:1001;
}
.voteSettings{
  width:100vw;
  height:100vh;
  position: fixed;
  z-index:1001;
}
.cog{
  transition:0.2s;
  color:rgb(100, 100, 121);
  cursor: pointer;
  float:right;
  font-size: 30px;
  margin-top:25.5px;
  margin-right:20px;
}
.cog:hover{
  transform: rotateZ(60deg);
}
.holder{
  padding-top:20px;
  padding-left: 20px;
  padding-bottom:20px;
  border-bottom:1px solid rgb(228, 228, 228);
}

.NamePosition{
  background-color:rgb(0, 212, 131);
  height:40px;
  line-height: 40px;
  padding-left:15px;
  padding-right:15px;
  vertical-align: middle;
  margin-top:20px;
  margin-right:20px;
  outline:none;
  font-size:18px;
  border:none;
  border-radius:5px;
  color:white;
  float:right;
}
.role{
  background-color:rgb(255, 202, 88);
  height:40px;
  line-height: 40px;
  padding-left:15px;
  padding-right:15px;
  vertical-align: middle;
  margin-top:20px;
  margin-right:20px;
  outline:none;
  font-size:18px;
  border:none;
  border-radius:5px;
  color:white;
  float:right;
}
.wrongNet{
    transition:0.2s;
  cursor: pointer;
  text-align: center;
  height:40px;
  line-height: 40px;
  padding-left:10px;
  padding-right:10px;
  width:150px;
  vertical-align: middle;
  margin-top:20px;
  margin-right:20px;
  font-size:18px;
  border:none;
  border-radius:5px;
  color:white;
  background-color:rgb(223, 92, 92);
  float:right;
}
.wrongNet:hover{
  background-color:rgb(192, 75, 75);
}
::placeholder{
  color:rgb(182, 182, 182)
}

.settingValue{
  padding-top:2px;
  float:right;
  width:38px;
  padding-left:5px;
  height:22px;
  font-size: 17px;
  border:1px solid rgb(0, 183, 255);
  border-radius:5px;
  margin-right:10px;
  margin-top:2px;
}
.submitHolder{
  font-size:15px;
  transition:0.2s;
  outline:none;
  border:none;
  border-radius:0 5px 5px 0px;
  color:white;
  background-color:rgb(44, 198, 143);
  border:none;
  margin-right:20px;
  float:right;
  height:30px;
  width:120px;
}
.submitHolder:hover{
    background-color:rgb(38, 168, 123);
}
.submitHolder:disabled{
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
  width:130px;
}
.holderButton:hover{
   background-color:rgb(223, 92, 92);
}
.holderButton:disabled{
   cursor: default;
   background-color:rgb(179, 179, 179);
}
.holderBalance{
  float:right;
  margin-top:7px;
}
.holderHeader{
   font-size: 18px;
   padding-top: 9px;
   padding-left: 20px;
   padding-bottom: 8px;
   border-bottom:1px solid rgb(228, 228, 228);
}
.requirements{
  display:inline-block;
  height:30px;
  background-color:rgb(228, 250, 255);
  width:fit-content;
  width:170px;
  font-size: 19px;
  text-align: center;
  line-height:30px;
  border-radius: 5px;
  left:0;
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

.tokenHolders{
  -webkit-box-shadow: -1px 4px 10px -1px rgba(34, 60, 80, 0.05);
  -moz-box-shadow: -1px 4px 10px -1px rgba(34, 60, 80, 0.05);
  box-shadow: -1px 4px 10px -1px rgba(34, 60, 80, 0.05);
  text-align:left;
  border:1px solid rgb(228, 228, 228);
  background-color:white;
  border-radius: 8px;
  width:80%;
  margin-left:10%;
  left:0;
}
.container{
  margin-bottom:40px;
}
.wrapper{
  width:80%;
  margin-left:10%;
}
.tokenName{
  background-color:rgb(228, 250, 255);
   font-weight: 100;
   padding-right:10px;
   padding-left:10px;
   border-radius:5px;
}
.infoToken2{
  position: absolute;
  text-align: right;
  right:0;
  top:0;
  line-height:2;
  top:6px;
  right:23px;
  font-weight: 600;
}
.infoToken{
  position: relative;
  top:8px;
  line-height:2;
  text-align: left;
  left:23px;
}
.tokenInfoHeader{
  font-size:30px;
  position:absolute;
  margin-top:-55px;
}
.fade-enter-active, .fade-leave-active {
  transition: opacity .5s;
}
.fade-enter, .fade-leave-to  {
  opacity: 0;
}
button{
  cursor: pointer;
}
.wallet{
  height:40px;
  line-height: 40px;
  padding-left:20px;
  padding-right:20px;
  width:120px;
  vertical-align: middle;
  margin-top:20px;
  margin-right:20px;
  overflow: hidden;
  text-overflow: ellipsis;
  outline:none;
  font-size:18px;
  border:none;
  border-radius:5px;
  color:white;
  background-color:rgb(0, 183, 255);
  float:right;
}
.connectWallet{
  height:40px;
  width:160px;
  margin-top:20px;
  margin-right:20px;
  outline:none;
  font-size:17px;
  border:none;
  border-radius:5px;
  color:white;
  background-color:rgb(0, 183, 255);
  transition:0.2s;
}
.connectWallet:hover{
  background-color:rgb(0, 157, 219);
}
.padding{
  height:80px;
}
.header{
  z-index:1;
  text-align: right;
  top:0;
  width:100%;
  position: fixed;
  height:80px;
  background-color:rgb(255, 255, 255);
  border-bottom:1px solid rgb(228, 228, 228);
  border-left:1px solid rgb(228, 228, 228);
}
.question-title{
  margin-left:30px;
  font-size:20px;
  margin-bottom:7px;
}
.submit{
  transition:0.2s;
  border-radius:0 5px 5px 0px;
  height:34px;
  border:none;
  background-color:rgb(0, 183, 255);
  width:130px;
  color:white;
  font-size:16px;
  vertical-align: top;
}
.submit:hover{
  background-color:rgb(0, 157, 219);
}
.submit:disabled{
  cursor: default;
  background-color:rgb(196, 196, 196);
}
.createVote{
  margin-top:40px;
  margin-bottom:20px;
  font-size:30px;
  text-align:left;
  margin-left:10%;
}
.home{
  width:100%;
}
.inputHolder{
  padding-left:7px;
  font-size:17px;
  text-align:left;
  height:26px;
  margin-left:5px;
  border:1px solid rgb(0, 183, 255);
  border-radius:5px 0px 0px 5px;
  width:calc(100% - 156px);
}
.inputQuestion{
  font-size:18px;
  text-align:left;
  height:30px;
  margin-left:30px;
  border:1px solid rgb(0, 183, 255);
  border-radius:5px 0px 0px 5px;
  width:calc(100% - 195px);
}
.tokenInfo{
  z-index:0;
  -webkit-box-shadow: -1px 4px 10px -1px rgba(34, 60, 80, 0.05);
  -moz-box-shadow: -1px 4px 10px -1px rgba(34, 60, 80, 0.05);
  box-shadow: -1px 4px 10px -1px rgba(34, 60, 80, 0.05);
  position:absolute;
  right:calc(10% - 13px);
  margin-top:-112px;
  border:1px solid rgb(228, 228, 228);
  background-color:white;
  width:300px;
  height:110px;
  border-radius: 8px;
}
.top-row{
   width:80%;
   margin-left:10%;
}
.questionInput{
  -webkit-box-shadow: -1px 4px 10px -1px rgba(34, 60, 80, 0.05);
  -moz-box-shadow: -1px 4px 10px -1px rgba(34, 60, 80, 0.05);
  box-shadow: -1px 4px 10px -1px rgba(34, 60, 80, 0.05);
  text-align:left;
  border:1px solid rgb(228, 228, 228);
  background-color:white;
  border-radius: 8px;
  padding-top:15px;
  padding-bottom:30px;
  width:calc(100% - 330px);
  left:0;
}
.lds-default {
  display: inline-block;
  position: relative;
  width: 80px;
  height: 80px;
}
.lds-default div {
  position: absolute;
  width: 8px;
  height: 8px;
  background: #326edf;
  border-radius: 50%;
  animation: lds-default 1.2s linear infinite;
}
.lds-default div:nth-child(1) {
  animation-delay: 0s;
  top: 37px;
  left: 66px;
}
.lds-default div:nth-child(2) {
  animation-delay: -0.1s;
  top: 22px;
  left: 62px;
}
.lds-default div:nth-child(3) {
  animation-delay: -0.2s;
  top: 11px;
  left: 52px;
}
.lds-default div:nth-child(4) {
  animation-delay: -0.3s;
  top: 7px;
  left: 37px;
}
.lds-default div:nth-child(5) {
  animation-delay: -0.4s;
  top: 11px;
  left: 22px;
}
.lds-default div:nth-child(6) {
  animation-delay: -0.5s;
  top: 22px;
  left: 11px;
}
.lds-default div:nth-child(7) {
  animation-delay: -0.6s;
  top: 37px;
  left: 7px;
}
.lds-default div:nth-child(8) {
  animation-delay: -0.7s;
  top: 52px;
  left: 11px;
}
.lds-default div:nth-child(9) {
  animation-delay: -0.8s;
  top: 62px;
  left: 22px;
}
.lds-default div:nth-child(10) {
  animation-delay: -0.9s;
  top: 66px;
  left: 37px;
}
.lds-default div:nth-child(11) {
  animation-delay: -1s;
  top: 62px;
  left: 52px;
}
.lds-default div:nth-child(12) {
  animation-delay: -1.1s;
  top: 52px;
  left: 62px;
}
@keyframes lds-default {
  0%, 20%, 80%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.5);
  }
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
.loading-status{
  position:absolute;
  height:100vh;
  width:100%;
  margin-top:0;
  top:0;
  background: #f7f8fa;
}
.loading-text{
  position:relative;
  top:calc(50% - 60px);
  font-size:26px;
  color:white;
}
</style>
