<template>
  <div id="app">
    <div id="nav">
      <div class="apps">APPS</div>
      <router-link class="tab" to="/">Voting</router-link> <br>
    </div>
    <router-view />
    <div id="background"></div>
  </div>
</template>

<style>
*{
  margin:0;
}

#background {
  background-color:rgb(249, 250, 252);
  height:100vh;
  width:100vw;
  top:0;
  left:0;
  position: fixed;
  z-index:-1
}
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  position: relative;
  color: #2c3e50;
  z-index:1
}
.apps{
  padding-left: 20px;
  color:#aaaaaa;
  margin-top:50px;
  margin-bottom:25px;
  font-size:14px;
}
.tab{
  transition: 0.2s;
  display: block;
  padding-left: 20px;
  height:35px;
  width:calc(100% - 20px);
  font-size:19px;
  padding-bottom:0px;
  padding-top:12px;
  margin:0;
  margin-top:-15px;
}
#nav {
  display:none;
  text-align: left;
  border-right:1px solid rgb(228, 228, 228);
  background-color:white;
  position:fixed;
  top:0;
  left:0;
  width:140px;
  height:100%;
}

#nav a {
  text-decoration: none;
  color: #2c3e50;
}

#nav .tab.router-link-exact-active{
  padding-left: 16px;
  background-color:rgb(239, 246, 250);
  border-left:4px solid rgb(0, 140, 255);
}
</style>
