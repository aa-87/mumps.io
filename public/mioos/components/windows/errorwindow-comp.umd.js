(function () {
  window["errorwindow-comp"]={
    props:['content','show'],
    data() {
      return {
        errorWindowShown:this.show || false,
        errorWindowDraggableElement: null,
        x: 0,
        y: 0,
        isDragging: false,
        offsetX: 0,
        offsetY: 0,
      };
    },
    mounted() {
    },
    methods: {
      startDrag(e) {
      this.isDragging = true;
      this.offsetX = e.clientX - this.x;
      this.offsetY = e.clientY - this.y;
      document.addEventListener('mousemove', this.onDrag);
      document.addEventListener('mouseup', this.stopDrag);
    },
    onDrag(e) {
      if (this.isDragging) {
        this.x = e.clientX - this.offsetX;
        this.y = e.clientY - this.offsetY;
      }
    },
    stopDrag() {
      this.isDragging = false;
      document.removeEventListener('mousemove', this.onDrag);
      document.removeEventListener('mouseup', this.stopDrag);
    },
    },
    computed: {
      style() {
        return `transform: translate3d(${this.x}px, ${this.y}px, 0); position: fixed;`;
      },
    },
    template: `
     <div :style="style" data-attr="error"  @mousedown="startDrag" v-if="errorWindowShown" class="z-[9990] shrink-0 absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
    <div class="window w-fit bg-[#e9e9d9]" >
        <div ref="errorWindowDraggableElement" class=" title-bar shrink-0"  >
            <div class="title-bar-text shrink-0">Error</div>
            <div class="flex items-center justify-center gap-1">
            <div  @click="errorWindowShown=false" 
            class="w-[22px] h-[22px] hover:shadow-inner hover:shadow-white rounded-sm transition-all duration-75 active:opacity-70 box-border ring-0 outline-none active:shadow-black close">
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
