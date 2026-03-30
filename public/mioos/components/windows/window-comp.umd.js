(function () {
  window["window-comp"] = {
    props:['id','position','titleBar'],
    data() {
      return {
        windowDraggableElement: null,
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
    <div data-attr="window" :style="style"  @mousedown="startDrag" :id="id" class="z-[990] shrink-0 absolute top-10">
    <div class="window w-fit bg-[#fcfcfe]">
        <div ref="windowDraggableElement" class=" title-bar shrink-0">
            <div class="title-bar-text shrink-0">{{ titleBar }}</div>
            <div class="flex items-center justify-center gap-1">
                <div
                    class="w-[22px] h-[22px] hover:shadow-inner hover:shadow-white rounded-sm transition-all duration-75 active:opacity-70 box-border ring-0 outline-none active:shadow-black minimize">
                </div>
                <div
                    class="w-[22px] h-[22px] hover:shadow-inner hover:shadow-white rounded-sm transition-all duration-75 active:opacity-70 box-border ring-0 outline-none active:shadow-black fullsize">
                </div>
                <div @click="removeWindow($event)"
                    class="w-[22px] h-[22px] hover:shadow-inner hover:shadow-white rounded-sm transition-all duration-75 active:opacity-70 box-border ring-0 outline-none active:shadow-black close">
                </div>
            </div>
        </div>
        <div class="p-4 select-none">
            <p>Hello world !</p>
            <p>{{ id }}</p>
            <button>ok</button>
        </div>
    </div>
</div>
`,
  };
})();
