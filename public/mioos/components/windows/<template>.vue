<template>
<div 
    ref="windowRef"
    :class="'window absolute flex flex-col bg-xp-yellow' + (animationEnabled ? ' transition duration-300 ' : ' ') +  (minimized ? 'opacity-0' : '')"
    @mousedown="hadleFocus"
    :style="'width:'+width+'px;' +'height:'+height+'px;' 
    +'opacity:0;position: absolute;border-top-left-radius: 8px;border-top-right-radius: 8px;padding: 0px;-webkit-font-smoothing: antialiased;'
    +'transform:' + (minimized ? (translateX + ' ' + translateY + ' scale(0.1)') : 'none' )    
    ">
    <div class="shrink-0">
        <mioos-title-bar-comp>
        </mioos-title-bar-comp>
    </div>
    <div class="grow shrink-0 relative shadow-xl">
        <slot></slot>
    </div>
</div>
</template>
