(function () {
  if (!window.Vue || !window.Vue.createApp) return;
  var app = window.Vue.createApp({
    components:{
     "rightclick-comp":window["rightclick-comp"],
     "selectarea-comp":window["selectarea-comp"],
     "window-comp":window["window-comp"],
     "errorwindow-comp":window["errorwindow-comp"],
    },
    data: function () {
      return { };
    },
    computed: {},
    mounted: function () {},
    beforeUnmount: function () {},
    methods: {},
  });
  app.mount("#app");
  window['mioosApp']=app
})();
