<template>
  <div class="home">
    <transition name="fade">
       <div key="1" v-if="pageLoading===false" class="container">

         <div class="voteSettings" v-if="showSettingsModal">
           <div class="voteSettingsBG" v-on:click="showSettings"></div>
            <div class="settingsContainer">
              <div class="settingsHolder">
                <div class="requirements">Minimum Support</div>
                  <button v-on:click="changeSupport(supportRequiredPct)" class="holderButton" :disabled="role==='Guest'||currentAccount.length===0||loadingSupport||!rightChainId">
                    <span v-if="!loadingSupport">Propose Change</span>
                    <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
                  </button>
                <input type="number" class="settingValue" v-model="supportRequiredPct">
              </div>
              <div class="settingsHolder">
                <div class="requirements">Minimum Approval</div>
                  <button v-on:click="changeMinQuorum(minAcceptQuorum)" class="holderButton" :disabled="role==='Guest'||currentAccount.length===0||loadingQuorum||!rightChainId">
                    <span v-if="!loadingQuorum">Propose Change</span>
                    <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
                  </button>
                <input type="number" class="settingValue" v-model="minAcceptQuorum">
              </div>
            </div>
         </div>

        <div class="header">
            <font-awesome-icon class="cog" v-if="role!=='Guest'" v-on:click="showSettings" :icon="['fas', 'cog']" />
            <div v-if="!rightChainId" class="wrongNet" v-on:click="switchNetwork">Wrong Network!</div>
            <button v-else-if="currentAccount.length===0" class="connectWallet" v-on:click="connectWallet">Connect wallet</button>
            <div v-else class="wallet">{{currentAccount[0]}}</div>
            <div v-if="userName||userPosition" class="NamePosition">{{userName}}{{userPosition&&userName?' | ':''}}{{userPosition}}</div>

            <div class="role">{{role}}</div>

        </div>
        <div class="padding"></div>
        <div v-if="role!=='Guest'" class="createProposal">Create Proposal</div>
          <div v-if="role!=='Guest'" class="top-row">
            <div class="questionInput">
              <div class="question-title">Question</div>
              <input class="inputQuestion" v-model="question">
              <button class="submit" :disabled="currentAccount.length===0 ||loadingCreate||!rightChainId||fileUploading" v-on:click="createProposal(question)">
                <div  v-if="loadingCreate||fileUploading"  class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
                <span v-else>Create Proposal</span>
              </button>
              <button class="submitFile" v-on:click="$refs.file.click()"  :disabled="currentAccount.length===0 ||!rightChainId||fileUploading||loadingCreate">
                <div v-if="fileUploading||loadingCreate" class="lds-dual-ring"></div>
                <font-awesome-icon v-else :icon="['fas', 'file']" />
              </button>
<div class="fileName">{{fileName}}</div>
              <input type="file"  @change="uploadFile" ref="file" style="display: none; position:absolute;" single>

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
          <div class="createProposal">Open Proposals - {{openProposals.length}}</div>
          <div class="wrapper">
            <QUESTION
              v-for="entry in openProposals"
              :key="entry.id"
              @update="update"
               @error="addError"
              :votingContract="votingContract"
              :question="entry"
              :votingAddress="votingAddress"
              :currentAccount="currentAccount[0]"
              :provider="provider"
              :isTokenHolder="role!=='Guest'&&role!=='Expert'"
              :updateList="updateList"
              :isRightChain="rightChainId"
              />
            </div>

          <div v-if="role==='Admin'||role==='Manager'" class="createProposal">Token Holders</div>
            <div v-if="role==='Admin'||role==='Manager'" class="tokenHolders">
              <div class="holderHeader">Holder</div>
              <HOLDER
                v-for="holder in holders"
                :key="holder.address"
                @update="update"
                @error="addError"
                :managerContract="managerContract"
                :provider="provider"
                :holder="holder"
                :currentAccount="currentAccount"
                :isRightChain="rightChainId"
              />
              <div class="holder">
                <input class="inputHolder" placeholder="Address" v-model="newAddress">
                <button class="submitHolder" :disabled="role==='Guest'||currentAccount.length===0||loadingMint||!rightChainId" v-on:click="mint(newAddress)">
                  <span v-if="!loadingMint">Add Participant</span>
                  <div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
                </button>
              </div>
            </div>

          <div class="createProposal">Closed Proposals - {{closedProposals.length}}</div>
            <div class="wrapper">
              <QUESTION
                v-for="entry in closedProposals"
                :key="entry.id"
                @update="update"
                 @error="addError"
                :votingContract="votingContract"
                :question="entry"
                :votingAddress="votingAddress"
                :currentAccount="currentAccount[0]"
                :provider="provider"
                :isTokenHolder="role!=='Guest'&&role!=='Expert'"
                :updateList="updateList"
                :isRightChain="rightChainId"
                />
            </div>
        </div>
     <div key="2" v-else class="loading-status">
        <div class="loading-text"><div class="lds-default"><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div><div class="text"></div></div>
    </div>
    </transition>
     <!-- v-if="errors.length > 0 && errors[errors.length - 1]||true" -->
     <div class="errorContainer">
      <transition-group name="errorTransition" >
        <div v-for="(error,index) in errors" class="error" :key="error.key">
          {{error.item}}
          <font-awesome-icon class="closeErrors" v-on:click="errors.splice(index, 1)" :icon="['fas', 'times']" />
        </div>
      </transition-group>
    </div>
  </div>
</template>

<script>
import { ethers } from 'ethers'
import Question from '../components/Question.vue'
import Holder from '../components/Holder.vue'
import votingABI from '../ABIs/voting.json'
import tokensABI from '../ABIs/tokens.json'
import tokenABI from '../ABIs/miniMe.json'
import aclABI from '../ABIs/acl.json'
import managerABI from '../ABIs/manager.json'
import { encodeCallScript } from '@aragon/connect-core'
import IPFS from 'ipfs-api'
// import IPFS from 'ipfs-http-client'

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
      ipfsUrl: 'https://ipfs.io/ipfs/',

      votingAddress: '0x16b14b163f40e603ae85cb078c5cb514319878c3',
      tokensAddress: '0x4f2983ddbd6de8fa0a13a6de99a535121fca3c23',
      tokenAddress: '0x965bb2f812a57ac0fcbb60829e3f4d9a07561608',
      ACLAddress: '0x81745c08facedb82b8b422b0384d585aaea8ac9f',
      managerAddress: '0x52656eba5b360959c7707a0fcba489d5af1625e1',

      provider: null,
      voting: null,
      question: '',
      tokens: null,
      token: {},
      openProposals: [],
      closedProposals: [],
      loadingCreate: false,
      loadingMint: false,
      loadingSupport: false,
      loadingQuorum: false,
      pageLoading: true,
      updateList: false,
      holders: [],
      newAddress: '',
      minAcceptQuorum: 0,
      supportRequiredPct: 0,
      votingContract: null,
      tokensContract: null,
      tokenContract: null,
      ACLContract: null,
      managerContract: null,
      rightChainId: false,
      manager: null,
      userName: null,
      userPosition: null,
      showSettingsModal: false,
      file: null,
      fileUploading: false,
      fileName: '',
      errors: [],
      role: null
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
      try {
        var providerChainId = (await this.provider.getNetwork()).chainId
      } catch (err) {
        this.addError("Can't fetch network chainId. Please check your wallet network settings")
      }
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
    this.managerContract = new ethers.Contract(this.managerAddress, managerABI, this.provider)

    try {
      this.token.name = await this.tokenContract.name()
      this.token.symbol = await this.tokenContract.symbol()
      this.token.transferable = await this.tokenContract.transfersEnabled()
      this.manager = await this.managerContract.manager()
    } catch (err) {
      this.addError("Can't fetch token info. Please try again later")
    }

    // Initialize IPFS interface
    this.ipfs = new IPFS({ host: 'ipfs.infura.io', port: 5001, protocol: 'https' })

    await this.update()
    this.pageLoading = false
  },

  methods: {
    addError (elem) {
      const item = { item: elem, key: Math.random() }
      this.errors.push(item)
      if (this.errors.length > 3) {
        this.errors.splice(0, 1)
      }
      setTimeout(() => {
        const index = this.errors.findIndex((a) => { return a.key === item.key })
        if (index !== -1) { this.errors.splice(this.errors.findIndex((a) => { return a.key === item.key }), 1) }
      }, 7000)
    },
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

    async uploadFile (event) {
      const file = event.target.files[0]
      if (file) {
        this.fileName = event.target.files[0].name
        this.fileUploading = true
        const fileTypes = ['pdf'] // ['jpg', 'jpeg', 'png', 'txt', 'pdf', 'mp3', 'mp4', 'webm']
        const extension = file.name.split('.').pop().toLowerCase()
        if (!fileTypes.includes(extension)) {
          this.fileName = ''
          this.$refs.file.value = null
          this.fileUploading = false
          this.addError('The file must have .PDF extension.')
          return
        }
        const reader = new window.FileReader()
        reader.readAsArrayBuffer(file)
        reader.onloadend = async () => {
          try {
            const buffer = await Buffer.from(reader.result)
            const result = await this.ipfs.add(buffer)
            this.file = this.ipfsUrl + result[0].path
            // this.createProposal('')
          } catch (err) {
            this.$refs.file.value = null
            this.fileName = ''
            this.addError("The file wasn't uploaded because of the IPFS error. Please try again later.")
          }
          this.fileUploading = false
        }
        return
      }
      this.fileName = ''
      this.file = null
    },

    async createProposal (question) {
      try {
        if (!this.file && question === '') {
          this.addError('Please enter a proposal or upload a file.')
        }
        const args = ['0x00000001', JSON.stringify({
          question: question,
          file: this.file ? this.file : ''
        })]
        /* if (this.file) {
          args = [this.file.script, obj]
        } else if (question !== '') {
          args = ['0x00000001', obj]
        } else {
          this.addError('Please enter a proposal or upload a file.')
        } */

        this.loadingCreate = true
        const iface = new ethers.utils.Interface(votingABI)
        const encodedData = iface.encodeFunctionData('newVote', args)
        const script = encodeCallScript([{ to: this.votingAddress, data: encodedData }])
        const tx = await this.tokensContract.connect(this.provider.getSigner()).forward(
          script,
          {
            gasPrice: '0'
          }
        )
        await this.waitForTransaction(tx)
      } catch (err) {
        this.addError("The transaction wasn't sent.")
        console.log(err)
      }
      this.question = ''
      this.loadingCreate = false
      this.$refs.file.value = null
      this.fileName = ''
      this.file = null
    },

    async mint (to) {
      try {
        if (ethers.utils.isAddress(to)) {
          this.loadingMint = true
          const tx = await this.managerContract.connect(this.provider.getSigner()).mint(
            to,
            {
              gasPrice: '0'
            }
          )
          await this.waitForTransaction(tx)
        } else {
          this.addError('Please enter a valid address.')
        }
      } catch (err) {
        this.addError('The transaction was rejected.')
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
        } else {
          this.addError('Please enter a valid value. (value >= 0 & value <= 100)')
        }
      } catch (err) {
        this.addError('The transaction was rejected.')
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
        } else {
          this.addError('Please enter a valid value. (value >= 0 & value <= 100)')
        }
      } catch (err) {
        this.addError('The transaction was rejected.')
        console.log(err)
      }
      this.loadingSupport = false
    },

    async waitForTransaction (transaction) {
      try {
        var tx = await transaction.wait()
      } catch (err) {
        this.addError('The transaction was rejected.')
        console.log(err)
      }
      await this.update()
      return tx
    },

    async update () {
      try {
        const tokenHolders = await this.tokenContract.getTokenHolders()
        const adminList = await this.managerContract.getAdmins()

        this.holders = await Promise.all(tokenHolders.map(async (item) => ({
          ...item,
          role: await (new Promise((resolve) => {
            if (item.holder.toLowerCase() === this.manager.toLowerCase()) {
              resolve('Manager')
            }
            if (adminList.includes(item.holder)) {
              resolve('Admin')
            }
            this.managerContract.hasVotePermission(item.holder).then((res) => {
              if (!res) {
                resolve('Expert')
              } else {
                resolve('Member')
              }
            })
          }))
        })))
        const sortedBy = {
          Manager: 0,
          Admin: 1,
          Expert: 2,
          Member: 3
        }
        this.holders = this.holders.sort((a, b) => sortedBy[a.role] - sortedBy[b.role])
        if (this.currentAccount[0]) {
          var accountInfo = this.holders.find((a) => { return a.holder.toLowerCase() === this.currentAccount[0].toLowerCase() })
          if (accountInfo) {
            this.userName = accountInfo.name
            this.userPosition = accountInfo.position
            this.role = accountInfo.role
          } else {
            this.userName = null
            this.userPosition = null
            this.role = 'Guest'
          }
        } else {
          this.userName = null
          this.userPosition = null
          this.role = 'Guest'
        }

        this.token.totalSupply = await this.tokenContract.totalSupply()
        this.minAcceptQuorum = parseInt(ethers.utils.formatEther(await this.votingContract.minAcceptQuorumPct()) * 100)
        this.supportRequiredPct = parseInt(ethers.utils.formatEther(await this.votingContract.supportRequiredPct()) * 100)

        const votesLength = await this.votingContract.votesLength()

        let votes = []
        for (let i = 0; i < votesLength; i++) {
          votes.push(await this.votingContract.getVote(i))
        }
        votes = votes.map((item, index) => ({
          ...item,
          id: index
        }))

        votes = votes.sort((a, b) => {
          return a.startDate > b.startDate ? -1 : 1
        })
        this.openProposals = votes.filter((a) => {
          return a.executed === false && a.startDate - Math.floor(Date.now() / 1000) + 86400 > 0
        })
        this.closedProposals = votes.filter((a) => {
          return a.executed === true || a.startDate - Math.floor(Date.now() / 1000) + 86400 < 0
        })
        this.updateList = !this.updateList
      } catch (err) {
        this.addError('An error occured while fetching the data. Please try again later')
        console.log(err)
      }
      return true
    }
  }
}
</script>
<style scoped>
.fileName{
  color:rgb(0, 183, 255);
  position:absolute;
  margin-left:30px;
  margin-top:7px;
}
.closeErrors{
  transition:0.1s;
  position:absolute;
  right:40px;
}
.closeErrors:hover{
  color:rgb(255, 202, 202);
}
.errorContainer{
  position:fixed;
  width:100vw;
  bottom:0;
  right:0;
  left:0
}
.error{
  display: inline-block;
  transition:0.3s;
  position:relative;
  bottom: 0;
  width:100vw;
  background-color:rgb(255, 116, 116);
  color:white;
  padding-top:20px;
  padding-bottom:140px;
  border-top:1px solid rgb(255, 154, 154);
  margin-bottom:-120px;
}
.fileTypes{
  margin-left:30px;
  height:0px;
  padding-top:12px;
  padding-bottom:4px;
}
.file{
  transition:0.1s;
  font-size: 25px;
  color:rgb(117, 117, 117);
}
.file:hover{
  color:rgb(87, 87, 87);
}
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

.errorTransition-enter-active, .errorTransition-leave-active {
  transition: all .3s;
}
.errorTransition-enter, .errorTransition-leave-to  {
 /* bottom:-60px;*/
 opacity:0;
  transform: translateY(60px);
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
.submitFile{
  transition:0.2s;
  border-radius:7px;
  height:34px;
  border:none;
  background-color:rgb(0, 183, 255);
  width:40px;
  color:white;
  font-size:16px;
  vertical-align: top;
  margin-left:5px;
}
.submitFile:hover{
  background-color:rgb(0, 157, 219);
}
.submitFile:disabled{
  cursor: default;
  background-color:rgb(196, 196, 196);
}
.submit{
  transition:0.2s;
  border-radius:0 7px 7px 0px;
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
.createProposal{
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
  width:calc(100% - 235px);
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
  padding-top:12px;
  padding-bottom:33px;
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

.lds-dual-ring {
  display: inline-block;
  width: 17px;
  height: 17px;
  margin-left:-6px;
  margin-top:-6px;
}
.lds-dual-ring:after {
  content: " ";
  display: block;
  width: 17px;
  height: 17px;
  border-radius: 50%;
  border: 4px solid #fff;
  border-color: #fff transparent #fff transparent;
  animation: lds-dual-ring 1.2s linear infinite;
}
@keyframes lds-dual-ring {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

</style>
