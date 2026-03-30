(function () {
  window["clock-comp"]={
    data() {
      return {
        thme:'88:88'
      };
    },
    mounted() {
    setInterval(() => {
        const temptime = new Date()
        var hours = temptime.getHours();
        var minutes = temptime.getMinutes();  
        this.time = minutes <10 ? hours + ":0" +minutes : hours + ":"+minutes 
    }, 100);  
    },
    methods: {
    },
    template: `
<div class="text-sm leading-5">
    {{ time }}
</div>`,
  };
})();
