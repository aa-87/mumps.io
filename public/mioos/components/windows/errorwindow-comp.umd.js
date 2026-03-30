(function () {
  window["errorwindow-comp"]={
    props:['content','show'],
    data() {
      return {
        errorWindowShown:this.show || false
      };
    },
    mounted() {
    },
    methods: {
    },
    template: `
     <div data-attr="error" v-if="errorWindowShown" class="z-[9990] shrink-0 absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
    <div  class="window w-fit bg-[#e9e9d9]" >
        <div class=" title-bar shrink-0"  >
            <div class="title-bar-text shrink-0">Error</div>
            <div class="flex items-center justify-center gap-1">
            <div  @click="errorWindowShown=false" class="w-[22px] h-[22px] hover:shadow-inner hover:shadow-white rounded-sm transition-all duration-75 active:opacity-70 box-border ring-0 outline-none active:shadow-black close">
            </div>
            </div>
        </div>
        <div class="p-4 select-none flex flex-col items-center justify-center gap-2">
            <div class="flex gap-4">
                <img src="/public/mioos/assets/error.png" alt="error">
                <p>{{ content }}</p>
            </div>
            <button @click="errorWindowShown=false" class="px-4">OK</button>
        </div>
    </div>
    </div>
  `,
  };
})();
