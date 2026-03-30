(function () {
  window["mycomputer-comp"] = {
    data() {
      return {
        computerwindowDraggableElement: null,
        x: 0,
        y: 0,
        isDragging: false,
        offsetX: 0,
        offsetY: 0,
      };
    },
    mounted() {},
    methods: {
      startDrag(e) {
        this.isDragging = true;
        this.offsetX = e.clientX - this.x;
        this.offsetY = e.clientY - this.y;
        document.addEventListener("mousemove", this.onDrag);
        document.addEventListener("mouseup", this.stopDrag);
      },
      onDrag(e) {
        if (this.isDragging) {
          this.x = e.clientX - this.offsetX;
          this.y = e.clientY - this.offsetY;
        }
      },
      stopDrag() {
        this.isDragging = false;
        document.removeEventListener("mousemove", this.onDrag);
        document.removeEventListener("mouseup", this.stopDrag);
      },
    },
    computed: {
      style() {
        return `transform: translate3d(${this.x}px, ${this.y}px, 0); position: fixed;`;
      },
    },
    template: `
    <div :style="style" data-attr="computerwindow" class="z-[9990]  shrink-0 absolute"  @mousedown="startDrag">
    <div  class="window w-[606px] h-[448px] bg-[#fcfcfe] !overflow-hidden ">
        <div ref="computerwindowDraggableElement" class=" title-bar shrink-0" >
            <div  class="title-bar-text shrink-0">
                <div class="flex items-center justify-start gap-1">
          <img draggable="false" src="/public/mioos/assets/computer.png" alt="folder" class="w-4">
          <p class="text-xs text-white">My Computer</p>
          </div>
            </div>
            <div class="flex items-center justify-center gap-1">
            <div   class="w-[22px] h-[22px] hover:shadow-inner hover:shadow-white rounded-sm transition-all duration-75 active:opacity-70 box-border ring-0 outline-none active:shadow-black minimize">
            </div>
            <div  class="w-[22px] h-[22px] hover:shadow-inner hover:shadow-white rounded-sm transition-all duration-75 active:opacity-70 box-border ring-0 outline-none active:shadow-black fullsize">
            </div>
            <div class="w-[22px] h-[22px] hover:shadow-inner hover:shadow-white rounded-sm transition-all duration-75 active:opacity-70 box-border ring-0 outline-none active:shadow-black close">
            </div>
            </div>
        </div>
        <div class="select-none  !inset-1 translate-x-[3px] flex flex-wrap items-start justify-start" style="height: calc(100% - 32px);">
            <!-- top area -->
            <div class="bg-[#efeede] w-[600px] h-[93px] border-b-2 border-[#ece9d8] flex flex-col items-start justify-start">
                <ul class="flex text-xs  gap-4 px-4 border-b border-[#d6d7bc] w-full py-1">
                    <li class="">File</li>
                    <li class="">Edit</li>
                    <li class="">View</li>
                    <li class="">Favorites</li>
                    <li class="">Tools</li>
                    <li class="">Help</li>
                </ul>
                <ul class="flex text-xs gap-4 px-4 border-b border-[#d6d7bc] w-full py-1">
                    <li class=" flex items-center justify-center flex-col"><img class="h-4 w-4" draggable="false" src="/public/mioos/assets/mini/arro2w.png" alt="menuicon"> Back</li>
                    <li class=" flex items-center justify-center flex-col  opacity-60"><img class="h-4 w-4" draggable="false" src="/public/mioos/assets/mini/arrowgray.png" alt="menuicon"> Forward</li>
                    <li class=" flex items-center justify-center flex-col border-r-2 border-[#d6d7bc] pr-4"><img class="h-4 w-4" draggable="false" src="/public/mioos/assets/mini/up.png" alt="menuicon"> Up</li>
                    <li class=" flex items-center justify-center flex-col"><img class="h-4 w-4" draggable="false" src="/public/mioos/assets/mini/search.png" alt="menuicon"> Search</li>
                    <li class=" flex items-center justify-center flex-col border-r-2 border-[#d6d7bc] pr-4"><img class="h-4 w-4" draggable="false" src="/public/mioos/assets/mini/folders.png" alt="menuicon"> Folders</li>
                    <li class=" flex items-center justify-center flex-col"><img class="h-3 mb-1 w-4" draggable="false" src="/public/mioos/assets/mini/display.png" alt="menuicon"> Views</li>
                </ul>
                <ul class="flex text-xs gap-4 px-2 border-b border-[#d6d7bc] w-full py-1">
                    <li>Adress</li>
                    <li class="bg-white border border-[#7d9bb1] px-2 w-full h-full cursor-text group flex items-center justify-start"> <img draggable="false" src="/public/mioos/assets/computer.png" class="h-3" alt="computer"> <p class="group-active:text-white group-active:bg-[#316ac5] w-fit px-2 my-[1px] ml-2">My Computer</p></li>
                    <li class="flex items-center justify-center gap-1"><img draggable="false" src="/public/mioos/assets/mini/goarrow.png" alt="go"> Go</li>
                </ul>
            </div>
            <!-- left area -->
            <div class="w-[180px] h-[320px] shrink-0  bg-gradient-to-t from-[#6375d6] to-[#7ba2e7]">
                <details open class="bg-[#d6dff7] text-[#215dc6] text-xs m-2  rounded-t-md" >
                    <summary class="bg-gradient-to-r from-white  to-[#cad6f7] font-extrabold rounded-t-md flex items-center justify-between px-2 py-[2px] "><p class="text-xs scale-75">System Tasks</p> <img draggable="false" src="/public/mioos/assets/mini/arrdown.png" alt="arrows"></summary>
                    <ul class="flex items-start justify-start flex-col gap-1">
                        <li class="flex items-center justify-start gap-1 pl-2 cursor-pointer pt-2">
                            <img draggable="false" src="/public/mioos/assets/mini/info.png" alt="sidemenuicon">
                            <p class="scale-75 origin-left">View system information</p>
                        </li>
                        <li class="flex items-center justify-start gap-1 pl-2 cursor-pointer">
                            <img draggable="false" src="/public/mioos/assets/mini/removeprograms.png" alt="sidemenuicon">
                            <p class="scale-75 origin-left">Add or remove programs</p>
                        </li>
                        <li class="flex items-center justify-start gap-1 pl-2 cursor-pointer pb-2">
                            <img draggable="false" src="/public/mioos/assets/mini/setting.png" alt="sidemenuicon">
                            <p class="scale-75 origin-left">Change a setting</p>
                        </li>
                    </ul>
                </details>
                <details open class="bg-[#d6dff7] text-[#215dc6] text-xs m-2  rounded-t-md" >
                    <summary class="bg-gradient-to-r from-white  to-[#cad6f7] font-extrabold rounded-t-md flex items-center justify-between px-2 py-[2px] "><p class="text-xs scale-75">Other Places</p> <img draggable="false" src="/public/mioos/assets/mini/arrdown.png" alt="arrows"></summary>
                    <ul class="flex items-start justify-start flex-col gap-1">
                        <li class="flex items-center justify-start gap-1 pl-2 cursor-pointer pt-2">
                            <img draggable="false" src="/public/mioos/assets/mini/network.png" alt="sidemenuicon">
                            <p class="scale-75 origin-left">My Network Places</p>
                        </li>
                        <li class="flex items-center justify-start gap-1 pl-2 cursor-pointer">
                            <img draggable="false" src="/public/mioos/assets/mini/documents.png" alt="sidemenuicon">
                            <p class="scale-75 origin-left">My Documents</p>
                        </li>
                        <li class="flex items-center justify-start gap-1 pl-2 cursor-pointer ">
                            <img draggable="false" src="/public/mioos/assets/mini/shared.png" alt="sidemenuicon">
                            <p class="scale-75 origin-left">Shared Documents</p>
                        </li>
                        <li class="flex items-center justify-start gap-1 pl-2 cursor-pointer pb-2">
                            <img draggable="false" src="/public/mioos/assets/mini/setting.png" alt="sidemenuicon">
                            <p class="scale-75 origin-left">Control Panel</p>
                        </li>
                    </ul>
                </details>
                <details open class="bg-[#d6dff7] text-[#215dc6] text-xs m-2  rounded-t-md" >
                    <summary class="bg-gradient-to-r from-white  to-[#cad6f7] font-extrabold rounded-t-md flex items-center justify-between px-2 py-[2px] "><p class="text-xs scale-75">Details</p> <img draggable="false" src="/public/mioos/assets/mini/arrdown.png" alt="arrows"></summary>
                    <p class="text-xs font-extrabold origin-left scale-75 pl-4 pt-1 text-black">My Computer</p>
                    <p class="text-xs font-thin origin-left scale-75 pl-4 pb-1 text-black">System Folder</p>
                </details>
            </div>
            <!-- right area -->
            <div class="w-[420px] h-[320px] bg-white">
                <ul>
                    <li>
                        <p class="font-bold text-xs px-4">Files Stored on This Computer</p>
                        <div class="bg-gradient-to-r from-blue-500 to-transparent w-64 h-px"></div>
                        <div class="w-full h-24 flex flex-wrap items-center justify-start pl-2 ">
                            <div class=" flex items-center justify-center gap-1 px-6 border border-transparent hover:border-teal-400 hover:bg-sky-400/70">
                                <img draggable="false" src="/public/mioos/assets/folderold.png" alt="folder" class="w-10">
                                <p class="text-xs">Shared Documents</p>
                            </div>
                            <div class=" flex items-center justify-center gap-1 px-6 border border-transparent hover:border-teal-400 hover:bg-sky-400/70">
                                <img draggable="false" src="/public/mioos/assets/folderold.png" alt="folder" class="w-10">
                                <p class="text-xs">User's Documents</p>
                            </div>
                            <div class=" flex items-center justify-center gap-1 px-6 border border-transparent hover:border-teal-400 hover:bg-sky-400/70">
                                <img draggable="false" src="/public/mioos/assets/folderold.png" alt="folder" class="w-10">
                                <p class="text-xs">Guest's Documents</p>
                            </div>
                        </div>
                    </li>
                    <li>
                        <p class="font-bold text-xs px-4">Hard Disk Drives</p>
                        <div class="bg-gradient-to-r from-blue-500 to-transparent w-64 h-px"></div>
                        <div class="w-full h-16  flex items-center justify-start pl-2">
                            <div class=" flex items-center justify-center gap-1 px-6 border border-transparent hover:border-teal-400 hover:bg-sky-400/70">
                                <img draggable="false" src="/public/mioos/assets/disk.png" alt="disk" class="w-10">
                                <p class="text-xs">Local Disk (C:)</p>
                            </div>
                        </div>
                    </li>
                    <li>
                        <p class="font-bold text-xs px-4">Devices With Removable Storage</p>
                        <div class="bg-gradient-to-r from-blue-500 to-transparent w-64 h-px"></div>
                        <div class="w-full h-24  flex items-center justify-start pl-2 flex-wrap">
                            <div class=" flex items-center justify-center gap-1 px-6 border border-transparent hover:border-teal-400 hover:bg-sky-400/70">
                                <img draggable="false" src="/public/mioos/assets/cddisk.png" alt="cd" class="w-10">
                                <p class="text-xs">CD Drive (D:)</p>
                            </div>
                            <div class=" flex items-center justify-center gap-1 px-6 border border-transparent hover:border-teal-400 hover:bg-sky-400/70">
                                <img draggable="false" src="/public/mioos/assets/flopydisk.png" alt="flopy" class="w-10">
                                <p class="text-xs">Flopy (A:)</p>
                            </div>
                        </div>
                    </li>
                </ul>
            </div>
        </div>
    </div>
    </div>`, };
})();
