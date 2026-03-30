(function () {
  window["taskbar-comp"]={
 components: {
      "clock-comp": window["clock-comp"],
      "startmenu-comp": window["startmenu-comp"],
    },
    data() {
      return {
        fullScreen:false,
        soundOn:true,
        openMsnWindow:false,
        openComputerWindow:false,
        isOpenStartMenu:true,
        selectedFolderTab:'messenger',
        folders:['AAA','BBB','CCC','DDD']
      };
    },
    mounted() {
    },
    methods: {
    },
    template: `
        <div data-attr="taskbar" class="taskbar flex items-center justify-start z-[9999]">
          <div @click="isOpenStartMenu = !isOpenStartMenu" class="taskbar__start flex items-center justify-center gap-1 rounded-r-lg  ">
            <img draggable="false"  class="taskbar__start--logo !w-5 !h-5" src="/public/mioos/assets/xplogo.png" alt="Windows">
              <p class="tracking-wider pr-2">start</p>
          </div>
          <img draggable="false" class="mx-4 w-5" src="/public/mioos/assets/iexplorer.png" alt="iexplorer">
          <!-- folder tab -->
          <div @click="selectedFolderTab='window'"  :class=" (selectedFolderTab=='window'?'!bg-[#1658dd] !border-[#082875] ':' ') + 'w-40 h-[80%] tab mt-px mr-1 px-2 gap-1 border-t border-y border-[#255be1] rounded-sm bg-[#3980f4] hover:bg-[#1b50b8] hover:border-[#082875] flex items-center justify-start'" v-for="i in folders.length" :key="i">
          <img draggable="false" src="/public/mioos/assets/explorer.exe_14_252-3.png" alt="folder" class="w-4">
          <p class="text-xs text-white">window</p>
          </div>
          <!-- computer tab -->
          <div @click="selectedFolderTab='computer'" v-if="openComputerWindow" :class=" (selectedFolderTab=='computer'?'!bg-[#1658dd] !border-[#082875]':' ') + 'w-40 h-[80%] tab mt-px mr-1 px-2 gap-1 border-t border-y border-[#255be1] rounded-sm bg-[#3980f4] hover:bg-[#1b50b8] hover:border-[#082875] flex items-center justify-start'">
          <img draggable="false" src="/public/mioos/assets/computer.png" alt="folder" class="w-4">
          <p class="text-xs text-white">My Computer</p>
          </div>
          <!-- msn tab -->
          <div @click="selectedFolderTab='messenger'" v-if="openMsnWindow"  :class=" (selectedFolderTab=='messenger'?'!bg-[#1658dd] !border-[#082875]':' ') + 'w-40 h-[80%] tab mt-px mr-1 px-2 gap-1 border-t border-y border-[#255be1] rounded-sm bg-[#3980f4] hover:bg-[#1b50b8] hover:border-[#082875] flex items-center justify-start'">
          <img draggable="false" src="public/mioos/assets/msnlogo.png" alt="folder" class="w-4">
          <p class="text-xs text-white">Live Messenger</p>
          </div>
          
          <div class="taskbar__end ml-auto h-full w-fit text-white border box-border border-t-[#075dca] border-b-[#0a5bc6] border-r-transparent border-l-black flex items-center justify-end px-2 pt-1 text-sm gap-1">
           <img draggable="false" src="public/mioos/assets/bluetooth.png" alt="icon">
           <div class="relative">
            <div v-if="fullScreen" class="w-52 drop-shadow-lg text-xs bg-white absolute select-none bottom-6 right-2 text-black border border-black px-2 py-1 rounded-lg rounded-br-none">
              <p class="font-bold flex gap-2"><img loading="eager" draggable="false" class="w-5" src="/public/mioos/assets/nfo.png" alt="icon"> Full Screen <img @click="fullScreen=false" loading="eager" draggable="false" class="ml-auto w-4 h-4 cursor-pointer opacity-30 hover:opacity-60 " src="/src/assets/xclose.png" alt="icon"></p>
              <p class="w-fit">Press F11 for better experience</p>
            </div>
            <img @click="fullScreen=true" draggable="false" src="/public/mioos/assets/fullsc.png" alt="icon">
           </div>
           <img draggable="false" src="/public/mioos/assets/gatewall.png" alt="icon">
           <img draggable="false" @click="soundOn = !soundOn" v-if="soundOn == true" src="/public/mioos/assets/soundon.png" alt="icon">
           <img draggable="false" @click="soundOn = !soundOn" v-if="soundOn == false" src="/public/mioos/assets/oundoff.png" alt="icon">
            <clock-comp></clock-comp>
          </div>
        </div>
            <startmenu-comp></startmenu-comp>`,
  };
})();
