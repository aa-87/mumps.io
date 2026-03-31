(function () {
  window["mioos-window-comp"]={
     components: {
      "mioos-title-bar-comp": window["mioos-title-bar-comp"],
    },
    data() {
      return {
        width:600,
        height:600,
        x: 0,
        y: 0,
        isDragging: false,
        offsetX: 0,
        offsetY: 0,
        translateX:0,
        translateY:0,
        minimized:false,
      };
    },
    mounted() {
    },
    methods: {
      handleFocus(e){
        this.startDrag(e)
      },
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
    getCenterPoint(rect){
        if(rect == null){
            return {x: document.body.offsetWidth*0.5, y: document.body.offsetHeight*0.5}
        }
        return {x: rect.x + rect.width*0.5, y: rect.y+rect.height*0.5}
    },
    onClickClose(){
    
    },
    onClickMaximize(){
      this.setPosition({top: 0, left: 0, width: node_ref.parentNode.offsetWidth, height: node_ref.parentNode.offsetHeight});
      this.maximized = true;
    },
    setPosition({top, left, width, height}){
        this.$ref.windowRef.style.top = `${top}px`;
        this.$ref.windowRef.style.left = `${left}px`;
        this.$ref.windowRef.style.width = `${width}px`;
        this.$ref.windowRef.style.height = `${height}px`;
    }
    },
    computed: {
      style() {
        return `transform: translate3d(${this.x}px, ${this.y}px, 0); position: fixed;`;
      },
    },
    template: `
    <div :style="style" ref="windowRef" >
    <div
    :class="'window absolute flex flex-col bg-xp-yellow' + (animationEnabled ? ' transition duration-300 ' : ' ') +  (minimized ? 'opacity-0' : '')"
    :style="';width:'+width+'px;' +'height:'+height+'px;' 
    +'position: absolute;border-top-left-radius: 8px;border-top-right-radius: 8px;padding: 0px;-webkit-font-smoothing: antialiased;'
    +'transform:' + (minimized ? (translateX + ' ' + translateY + ' scale(0.1)') : 'none' )
    ">
    <div class="shrink-0">
        <mioos-title-bar-comp  @mousedown="startDrag">
        </mioos-title-bar-comp>
    </div>
    <div class="grow shrink-0 relative shadow-xl">
        <slot></slot>
    </div>
</div></div>
  `,
  };
})();







