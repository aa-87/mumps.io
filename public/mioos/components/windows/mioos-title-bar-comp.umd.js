(function () {
  window["mioos-title-bar-comp"] = {
    props: ["content", "show"],
    data() {
      return {
        inactive: false,
        maximized: false,
        optionsIcon: "",
        optionsTitle: "ee",
        minimizeBtn: true,
        minimizeBtnDisabled: false,
        maximizeBtn: true,
        maximizeBtnDisabled: false,
        cloasBtn: true,
        closeBtnDisabled: false,
      };
    },
    mounted() {},
    methods: {
      handleMinimize: function () {
        console.log("Minimized");
      },
      hanldeMaximize: function () {
        console.log("Maximized");
      },
      handleClose: function () {
        console.log("Close");
      },
    },
    computed: {},
    template: `
    
      <div
    :class="
      'titlebar shrink-0 flex rounded-tl-lg rounded-tr-lg items-center justify-between  h-7 p-1 font-Trebuchet ' +
      (inactive
        ? 'bg-[linear-gradient(var(--titlebar-gradient-inactive))]'
        : 'bg-[linear-gradient(var(--titlebar-gradient))]')
    "
  >
    <img
      v-if="optionsIcon.length"
      :src="optionsIcon"
      width="20px"
      height="20px"
      class="ml-1"
      alt=""
    />
    <p
      class="text-white font-semibold mr-4 text-[12px] grow ml-1 leading-tight line-clamp-1 text-ellipsis"
    >
      {{optionsTitle}}
    </p>
    <div class="flex mr-0.5 shrink-0">
      <button
        v-if="minimizeBtn"
        :disabled="minimizeBtnDisabled"
        @click="handleMinimize"
        class="group w-5 h-5 ml-1 group"
      >
        <img
          src="/public/mioos/static/images/xp/icons/Minimize.png"
          :class="
            'w-full h-full ' +
            (minimizeBtnDisabled ? 'contrast-75' : 'group-hover:brightness-110')
          "
        />
      </button>
      <button
        v-if="maximizeBtn"
        :disabled="maximizeBtnDisabled"
        @click="hanldeMaximize"
        class="group w-5 h-5 ml-1 group"
      >
        <img
          v-if="maximized"
          src="/public/mioos/static/images/xp/icons/Restore.png"
          :class="
            'w-full h-full ' +
            (maximizeBtnDisabled ? 'contrast-75' : 'group-hover:brightness-110')
          "
        />

        <img
          v-if="!maximized"
          src="/public/mioos/static/images/xp/icons/Maximize.png"
          :class="
            'w-full h-full ' +
            (maximizeBtnDisabled ? 'contrast-75' : 'group-hover:brightness-110')
          "
        />
      </button>
      <button
        v-if="cloasBtn"
        :disabled="closeBtnDisabled"
        @click="handleClose"
        class="group w-5 h-5 ml-1 group"
      >
        <img
          src="/public/mioos/static/images/xp/icons/Exit.png"
          class="w-full h-full {close_btn_disabled ? 'contrast-75' : 'group-hover:brightness-110'}"
        />
      </button>
    </div>
  </div>
    
    `};
})();
