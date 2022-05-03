
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:
.text
.globl kern_entry
kern_entry:
    # reload temperate gdt (second time) to remap all physical memory
    # virtual_addr 0~4G=linear_addr&physical_addr -KERNBASE~4G-KERNBASE 
    lgdt REALLOC(__gdtdesc)
c0100000:	0f 01 15 18 70 11 00 	lgdtl  0x117018
    movl $KERNEL_DS, %eax
c0100007:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010000c:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010000e:	8e c0                	mov    %eax,%es
    movw %ax, %ss
c0100010:	8e d0                	mov    %eax,%ss

    ljmp $KERNEL_CS, $relocated
c0100012:	ea 19 00 10 c0 08 00 	ljmp   $0x8,$0xc0100019

c0100019 <relocated>:

relocated:

    # set ebp, esp
    movl $0x0, %ebp
c0100019:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010001e:	bc 00 70 11 c0       	mov    $0xc0117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c0100023:	e8 02 00 00 00       	call   c010002a <kern_init>

c0100028 <spin>:

# should never get here
spin:
    jmp spin
c0100028:	eb fe                	jmp    c0100028 <spin>

c010002a <kern_init>:
int kern_init(void) __attribute__((noreturn));

static void lab1_switch_test(void);

int
kern_init(void) {
c010002a:	55                   	push   %ebp
c010002b:	89 e5                	mov    %esp,%ebp
c010002d:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c0100030:	ba 68 89 11 c0       	mov    $0xc0118968,%edx
c0100035:	b8 36 7a 11 c0       	mov    $0xc0117a36,%eax
c010003a:	29 c2                	sub    %eax,%edx
c010003c:	89 d0                	mov    %edx,%eax
c010003e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100042:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100049:	00 
c010004a:	c7 04 24 36 7a 11 c0 	movl   $0xc0117a36,(%esp)
c0100051:	e8 de 5c 00 00       	call   c0105d34 <memset>

    cons_init();                // init the console
c0100056:	e8 71 15 00 00       	call   c01015cc <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c010005b:	c7 45 f4 c0 5e 10 c0 	movl   $0xc0105ec0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c0100062:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100065:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100069:	c7 04 24 dc 5e 10 c0 	movl   $0xc0105edc,(%esp)
c0100070:	e8 c7 02 00 00       	call   c010033c <cprintf>

    print_kerninfo();
c0100075:	e8 f6 07 00 00       	call   c0100870 <print_kerninfo>

    grade_backtrace();
c010007a:	e8 86 00 00 00       	call   c0100105 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010007f:	e8 cc 41 00 00       	call   c0104250 <pmm_init>

    pic_init();                 // init interrupt controller
c0100084:	e8 ac 16 00 00       	call   c0101735 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100089:	e8 fe 17 00 00       	call   c010188c <idt_init>

    clock_init();               // init clock interrupt
c010008e:	e8 ef 0c 00 00       	call   c0100d82 <clock_init>
    intr_enable();              // enable irq interrupt
c0100093:	e8 0b 16 00 00       	call   c01016a3 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c0100098:	eb fe                	jmp    c0100098 <kern_init+0x6e>

c010009a <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c010009a:	55                   	push   %ebp
c010009b:	89 e5                	mov    %esp,%ebp
c010009d:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000a7:	00 
c01000a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000af:	00 
c01000b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000b7:	e8 f8 0b 00 00       	call   c0100cb4 <mon_backtrace>
}
c01000bc:	c9                   	leave  
c01000bd:	c3                   	ret    

c01000be <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000be:	55                   	push   %ebp
c01000bf:	89 e5                	mov    %esp,%ebp
c01000c1:	53                   	push   %ebx
c01000c2:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000c5:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000cb:	8d 55 08             	lea    0x8(%ebp),%edx
c01000ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01000d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000d5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000d9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000dd:	89 04 24             	mov    %eax,(%esp)
c01000e0:	e8 b5 ff ff ff       	call   c010009a <grade_backtrace2>
}
c01000e5:	83 c4 14             	add    $0x14,%esp
c01000e8:	5b                   	pop    %ebx
c01000e9:	5d                   	pop    %ebp
c01000ea:	c3                   	ret    

c01000eb <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000eb:	55                   	push   %ebp
c01000ec:	89 e5                	mov    %esp,%ebp
c01000ee:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c01000f1:	8b 45 10             	mov    0x10(%ebp),%eax
c01000f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01000f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01000fb:	89 04 24             	mov    %eax,(%esp)
c01000fe:	e8 bb ff ff ff       	call   c01000be <grade_backtrace1>
}
c0100103:	c9                   	leave  
c0100104:	c3                   	ret    

c0100105 <grade_backtrace>:

void
grade_backtrace(void) {
c0100105:	55                   	push   %ebp
c0100106:	89 e5                	mov    %esp,%ebp
c0100108:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010010b:	b8 2a 00 10 c0       	mov    $0xc010002a,%eax
c0100110:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100117:	ff 
c0100118:	89 44 24 04          	mov    %eax,0x4(%esp)
c010011c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100123:	e8 c3 ff ff ff       	call   c01000eb <grade_backtrace0>
}
c0100128:	c9                   	leave  
c0100129:	c3                   	ret    

c010012a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010012a:	55                   	push   %ebp
c010012b:	89 e5                	mov    %esp,%ebp
c010012d:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100130:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100133:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100136:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100139:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010013c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100140:	0f b7 c0             	movzwl %ax,%eax
c0100143:	83 e0 03             	and    $0x3,%eax
c0100146:	89 c2                	mov    %eax,%edx
c0100148:	a1 40 7a 11 c0       	mov    0xc0117a40,%eax
c010014d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100151:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100155:	c7 04 24 e1 5e 10 c0 	movl   $0xc0105ee1,(%esp)
c010015c:	e8 db 01 00 00       	call   c010033c <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100161:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100165:	0f b7 d0             	movzwl %ax,%edx
c0100168:	a1 40 7a 11 c0       	mov    0xc0117a40,%eax
c010016d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100171:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100175:	c7 04 24 ef 5e 10 c0 	movl   $0xc0105eef,(%esp)
c010017c:	e8 bb 01 00 00       	call   c010033c <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c0100181:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100185:	0f b7 d0             	movzwl %ax,%edx
c0100188:	a1 40 7a 11 c0       	mov    0xc0117a40,%eax
c010018d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100191:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100195:	c7 04 24 fd 5e 10 c0 	movl   $0xc0105efd,(%esp)
c010019c:	e8 9b 01 00 00       	call   c010033c <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001a1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001a5:	0f b7 d0             	movzwl %ax,%edx
c01001a8:	a1 40 7a 11 c0       	mov    0xc0117a40,%eax
c01001ad:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b5:	c7 04 24 0b 5f 10 c0 	movl   $0xc0105f0b,(%esp)
c01001bc:	e8 7b 01 00 00       	call   c010033c <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001c1:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001c5:	0f b7 d0             	movzwl %ax,%edx
c01001c8:	a1 40 7a 11 c0       	mov    0xc0117a40,%eax
c01001cd:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d5:	c7 04 24 19 5f 10 c0 	movl   $0xc0105f19,(%esp)
c01001dc:	e8 5b 01 00 00       	call   c010033c <cprintf>
    round ++;
c01001e1:	a1 40 7a 11 c0       	mov    0xc0117a40,%eax
c01001e6:	83 c0 01             	add    $0x1,%eax
c01001e9:	a3 40 7a 11 c0       	mov    %eax,0xc0117a40
}
c01001ee:	c9                   	leave  
c01001ef:	c3                   	ret    

c01001f0 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001f0:	55                   	push   %ebp
c01001f1:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001f3:	5d                   	pop    %ebp
c01001f4:	c3                   	ret    

c01001f5 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c01001f5:	55                   	push   %ebp
c01001f6:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c01001f8:	5d                   	pop    %ebp
c01001f9:	c3                   	ret    

c01001fa <lab1_switch_test>:

static void
lab1_switch_test(void) {
c01001fa:	55                   	push   %ebp
c01001fb:	89 e5                	mov    %esp,%ebp
c01001fd:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100200:	e8 25 ff ff ff       	call   c010012a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100205:	c7 04 24 28 5f 10 c0 	movl   $0xc0105f28,(%esp)
c010020c:	e8 2b 01 00 00       	call   c010033c <cprintf>
    lab1_switch_to_user();
c0100211:	e8 da ff ff ff       	call   c01001f0 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100216:	e8 0f ff ff ff       	call   c010012a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010021b:	c7 04 24 48 5f 10 c0 	movl   $0xc0105f48,(%esp)
c0100222:	e8 15 01 00 00       	call   c010033c <cprintf>
    lab1_switch_to_kernel();
c0100227:	e8 c9 ff ff ff       	call   c01001f5 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010022c:	e8 f9 fe ff ff       	call   c010012a <lab1_print_cur_status>
}
c0100231:	c9                   	leave  
c0100232:	c3                   	ret    

c0100233 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100233:	55                   	push   %ebp
c0100234:	89 e5                	mov    %esp,%ebp
c0100236:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100239:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010023d:	74 13                	je     c0100252 <readline+0x1f>
        cprintf("%s", prompt);
c010023f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100242:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100246:	c7 04 24 67 5f 10 c0 	movl   $0xc0105f67,(%esp)
c010024d:	e8 ea 00 00 00       	call   c010033c <cprintf>
    }
    int i = 0, c;
c0100252:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100259:	e8 66 01 00 00       	call   c01003c4 <getchar>
c010025e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100261:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100265:	79 07                	jns    c010026e <readline+0x3b>
            return NULL;
c0100267:	b8 00 00 00 00       	mov    $0x0,%eax
c010026c:	eb 79                	jmp    c01002e7 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010026e:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100272:	7e 28                	jle    c010029c <readline+0x69>
c0100274:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010027b:	7f 1f                	jg     c010029c <readline+0x69>
            cputchar(c);
c010027d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100280:	89 04 24             	mov    %eax,(%esp)
c0100283:	e8 da 00 00 00       	call   c0100362 <cputchar>
            buf[i ++] = c;
c0100288:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010028b:	8d 50 01             	lea    0x1(%eax),%edx
c010028e:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100291:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100294:	88 90 60 7a 11 c0    	mov    %dl,-0x3fee85a0(%eax)
c010029a:	eb 46                	jmp    c01002e2 <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c010029c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002a0:	75 17                	jne    c01002b9 <readline+0x86>
c01002a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002a6:	7e 11                	jle    c01002b9 <readline+0x86>
            cputchar(c);
c01002a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002ab:	89 04 24             	mov    %eax,(%esp)
c01002ae:	e8 af 00 00 00       	call   c0100362 <cputchar>
            i --;
c01002b3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01002b7:	eb 29                	jmp    c01002e2 <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01002b9:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002bd:	74 06                	je     c01002c5 <readline+0x92>
c01002bf:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002c3:	75 1d                	jne    c01002e2 <readline+0xaf>
            cputchar(c);
c01002c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002c8:	89 04 24             	mov    %eax,(%esp)
c01002cb:	e8 92 00 00 00       	call   c0100362 <cputchar>
            buf[i] = '\0';
c01002d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002d3:	05 60 7a 11 c0       	add    $0xc0117a60,%eax
c01002d8:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002db:	b8 60 7a 11 c0       	mov    $0xc0117a60,%eax
c01002e0:	eb 05                	jmp    c01002e7 <readline+0xb4>
        }
    }
c01002e2:	e9 72 ff ff ff       	jmp    c0100259 <readline+0x26>
}
c01002e7:	c9                   	leave  
c01002e8:	c3                   	ret    

c01002e9 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c01002e9:	55                   	push   %ebp
c01002ea:	89 e5                	mov    %esp,%ebp
c01002ec:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01002f2:	89 04 24             	mov    %eax,(%esp)
c01002f5:	e8 fe 12 00 00       	call   c01015f8 <cons_putc>
    (*cnt) ++;
c01002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01002fd:	8b 00                	mov    (%eax),%eax
c01002ff:	8d 50 01             	lea    0x1(%eax),%edx
c0100302:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100305:	89 10                	mov    %edx,(%eax)
}
c0100307:	c9                   	leave  
c0100308:	c3                   	ret    

c0100309 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100309:	55                   	push   %ebp
c010030a:	89 e5                	mov    %esp,%ebp
c010030c:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010030f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100316:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100319:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010031d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100320:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100324:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100327:	89 44 24 04          	mov    %eax,0x4(%esp)
c010032b:	c7 04 24 e9 02 10 c0 	movl   $0xc01002e9,(%esp)
c0100332:	e8 16 52 00 00       	call   c010554d <vprintfmt>
    return cnt;
c0100337:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010033a:	c9                   	leave  
c010033b:	c3                   	ret    

c010033c <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c010033c:	55                   	push   %ebp
c010033d:	89 e5                	mov    %esp,%ebp
c010033f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100342:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100345:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100348:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010034b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010034f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100352:	89 04 24             	mov    %eax,(%esp)
c0100355:	e8 af ff ff ff       	call   c0100309 <vcprintf>
c010035a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010035d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100360:	c9                   	leave  
c0100361:	c3                   	ret    

c0100362 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c0100362:	55                   	push   %ebp
c0100363:	89 e5                	mov    %esp,%ebp
c0100365:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100368:	8b 45 08             	mov    0x8(%ebp),%eax
c010036b:	89 04 24             	mov    %eax,(%esp)
c010036e:	e8 85 12 00 00       	call   c01015f8 <cons_putc>
}
c0100373:	c9                   	leave  
c0100374:	c3                   	ret    

c0100375 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100375:	55                   	push   %ebp
c0100376:	89 e5                	mov    %esp,%ebp
c0100378:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010037b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c0100382:	eb 13                	jmp    c0100397 <cputs+0x22>
        cputch(c, &cnt);
c0100384:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0100388:	8d 55 f0             	lea    -0x10(%ebp),%edx
c010038b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010038f:	89 04 24             	mov    %eax,(%esp)
c0100392:	e8 52 ff ff ff       	call   c01002e9 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c0100397:	8b 45 08             	mov    0x8(%ebp),%eax
c010039a:	8d 50 01             	lea    0x1(%eax),%edx
c010039d:	89 55 08             	mov    %edx,0x8(%ebp)
c01003a0:	0f b6 00             	movzbl (%eax),%eax
c01003a3:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003a6:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003aa:	75 d8                	jne    c0100384 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01003ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003af:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003b3:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003ba:	e8 2a ff ff ff       	call   c01002e9 <cputch>
    return cnt;
c01003bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003c2:	c9                   	leave  
c01003c3:	c3                   	ret    

c01003c4 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003c4:	55                   	push   %ebp
c01003c5:	89 e5                	mov    %esp,%ebp
c01003c7:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003ca:	e8 65 12 00 00       	call   c0101634 <cons_getc>
c01003cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003d6:	74 f2                	je     c01003ca <getchar+0x6>
        /* do nothing */;
    return c;
c01003d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003db:	c9                   	leave  
c01003dc:	c3                   	ret    

c01003dd <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01003dd:	55                   	push   %ebp
c01003de:	89 e5                	mov    %esp,%ebp
c01003e0:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01003e3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003e6:	8b 00                	mov    (%eax),%eax
c01003e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01003eb:	8b 45 10             	mov    0x10(%ebp),%eax
c01003ee:	8b 00                	mov    (%eax),%eax
c01003f0:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01003f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01003fa:	e9 d2 00 00 00       	jmp    c01004d1 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c01003ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100402:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100405:	01 d0                	add    %edx,%eax
c0100407:	89 c2                	mov    %eax,%edx
c0100409:	c1 ea 1f             	shr    $0x1f,%edx
c010040c:	01 d0                	add    %edx,%eax
c010040e:	d1 f8                	sar    %eax
c0100410:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100413:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100416:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100419:	eb 04                	jmp    c010041f <stab_binsearch+0x42>
            m --;
c010041b:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010041f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100422:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100425:	7c 1f                	jl     c0100446 <stab_binsearch+0x69>
c0100427:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010042a:	89 d0                	mov    %edx,%eax
c010042c:	01 c0                	add    %eax,%eax
c010042e:	01 d0                	add    %edx,%eax
c0100430:	c1 e0 02             	shl    $0x2,%eax
c0100433:	89 c2                	mov    %eax,%edx
c0100435:	8b 45 08             	mov    0x8(%ebp),%eax
c0100438:	01 d0                	add    %edx,%eax
c010043a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010043e:	0f b6 c0             	movzbl %al,%eax
c0100441:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100444:	75 d5                	jne    c010041b <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100446:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100449:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010044c:	7d 0b                	jge    c0100459 <stab_binsearch+0x7c>
            l = true_m + 1;
c010044e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100451:	83 c0 01             	add    $0x1,%eax
c0100454:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100457:	eb 78                	jmp    c01004d1 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100459:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100460:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100463:	89 d0                	mov    %edx,%eax
c0100465:	01 c0                	add    %eax,%eax
c0100467:	01 d0                	add    %edx,%eax
c0100469:	c1 e0 02             	shl    $0x2,%eax
c010046c:	89 c2                	mov    %eax,%edx
c010046e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100471:	01 d0                	add    %edx,%eax
c0100473:	8b 40 08             	mov    0x8(%eax),%eax
c0100476:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100479:	73 13                	jae    c010048e <stab_binsearch+0xb1>
            *region_left = m;
c010047b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010047e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100481:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c0100483:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100486:	83 c0 01             	add    $0x1,%eax
c0100489:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010048c:	eb 43                	jmp    c01004d1 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c010048e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100491:	89 d0                	mov    %edx,%eax
c0100493:	01 c0                	add    %eax,%eax
c0100495:	01 d0                	add    %edx,%eax
c0100497:	c1 e0 02             	shl    $0x2,%eax
c010049a:	89 c2                	mov    %eax,%edx
c010049c:	8b 45 08             	mov    0x8(%ebp),%eax
c010049f:	01 d0                	add    %edx,%eax
c01004a1:	8b 40 08             	mov    0x8(%eax),%eax
c01004a4:	3b 45 18             	cmp    0x18(%ebp),%eax
c01004a7:	76 16                	jbe    c01004bf <stab_binsearch+0xe2>
            *region_right = m - 1;
c01004a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004ac:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004af:	8b 45 10             	mov    0x10(%ebp),%eax
c01004b2:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004b7:	83 e8 01             	sub    $0x1,%eax
c01004ba:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004bd:	eb 12                	jmp    c01004d1 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004c5:	89 10                	mov    %edx,(%eax)
            l = m;
c01004c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004cd:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01004d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004d4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004d7:	0f 8e 22 ff ff ff    	jle    c01003ff <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01004dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004e1:	75 0f                	jne    c01004f2 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01004e3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004e6:	8b 00                	mov    (%eax),%eax
c01004e8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004eb:	8b 45 10             	mov    0x10(%ebp),%eax
c01004ee:	89 10                	mov    %edx,(%eax)
c01004f0:	eb 3f                	jmp    c0100531 <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01004f2:	8b 45 10             	mov    0x10(%ebp),%eax
c01004f5:	8b 00                	mov    (%eax),%eax
c01004f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01004fa:	eb 04                	jmp    c0100500 <stab_binsearch+0x123>
c01004fc:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c0100500:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100503:	8b 00                	mov    (%eax),%eax
c0100505:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100508:	7d 1f                	jge    c0100529 <stab_binsearch+0x14c>
c010050a:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010050d:	89 d0                	mov    %edx,%eax
c010050f:	01 c0                	add    %eax,%eax
c0100511:	01 d0                	add    %edx,%eax
c0100513:	c1 e0 02             	shl    $0x2,%eax
c0100516:	89 c2                	mov    %eax,%edx
c0100518:	8b 45 08             	mov    0x8(%ebp),%eax
c010051b:	01 d0                	add    %edx,%eax
c010051d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100521:	0f b6 c0             	movzbl %al,%eax
c0100524:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100527:	75 d3                	jne    c01004fc <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100529:	8b 45 0c             	mov    0xc(%ebp),%eax
c010052c:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010052f:	89 10                	mov    %edx,(%eax)
    }
}
c0100531:	c9                   	leave  
c0100532:	c3                   	ret    

c0100533 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100533:	55                   	push   %ebp
c0100534:	89 e5                	mov    %esp,%ebp
c0100536:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100539:	8b 45 0c             	mov    0xc(%ebp),%eax
c010053c:	c7 00 6c 5f 10 c0    	movl   $0xc0105f6c,(%eax)
    info->eip_line = 0;
c0100542:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100545:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010054c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010054f:	c7 40 08 6c 5f 10 c0 	movl   $0xc0105f6c,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100556:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100559:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100560:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100563:	8b 55 08             	mov    0x8(%ebp),%edx
c0100566:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100569:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100573:	c7 45 f4 a8 71 10 c0 	movl   $0xc01071a8,-0xc(%ebp)
    stab_end = __STAB_END__;
c010057a:	c7 45 f0 80 1d 11 c0 	movl   $0xc0111d80,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100581:	c7 45 ec 81 1d 11 c0 	movl   $0xc0111d81,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100588:	c7 45 e8 b7 47 11 c0 	movl   $0xc01147b7,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c010058f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100592:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100595:	76 0d                	jbe    c01005a4 <debuginfo_eip+0x71>
c0100597:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010059a:	83 e8 01             	sub    $0x1,%eax
c010059d:	0f b6 00             	movzbl (%eax),%eax
c01005a0:	84 c0                	test   %al,%al
c01005a2:	74 0a                	je     c01005ae <debuginfo_eip+0x7b>
        return -1;
c01005a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005a9:	e9 c0 02 00 00       	jmp    c010086e <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005ae:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005bb:	29 c2                	sub    %eax,%edx
c01005bd:	89 d0                	mov    %edx,%eax
c01005bf:	c1 f8 02             	sar    $0x2,%eax
c01005c2:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005c8:	83 e8 01             	sub    $0x1,%eax
c01005cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01005d1:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005d5:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01005dc:	00 
c01005dd:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01005e0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01005e4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01005e7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01005eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005ee:	89 04 24             	mov    %eax,(%esp)
c01005f1:	e8 e7 fd ff ff       	call   c01003dd <stab_binsearch>
    if (lfile == 0)
c01005f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01005f9:	85 c0                	test   %eax,%eax
c01005fb:	75 0a                	jne    c0100607 <debuginfo_eip+0xd4>
        return -1;
c01005fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100602:	e9 67 02 00 00       	jmp    c010086e <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100607:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010060a:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010060d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100610:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0100613:	8b 45 08             	mov    0x8(%ebp),%eax
c0100616:	89 44 24 10          	mov    %eax,0x10(%esp)
c010061a:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100621:	00 
c0100622:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100625:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100629:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010062c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100630:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100633:	89 04 24             	mov    %eax,(%esp)
c0100636:	e8 a2 fd ff ff       	call   c01003dd <stab_binsearch>

    if (lfun <= rfun) {
c010063b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010063e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100641:	39 c2                	cmp    %eax,%edx
c0100643:	7f 7c                	jg     c01006c1 <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100645:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100648:	89 c2                	mov    %eax,%edx
c010064a:	89 d0                	mov    %edx,%eax
c010064c:	01 c0                	add    %eax,%eax
c010064e:	01 d0                	add    %edx,%eax
c0100650:	c1 e0 02             	shl    $0x2,%eax
c0100653:	89 c2                	mov    %eax,%edx
c0100655:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100658:	01 d0                	add    %edx,%eax
c010065a:	8b 10                	mov    (%eax),%edx
c010065c:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010065f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100662:	29 c1                	sub    %eax,%ecx
c0100664:	89 c8                	mov    %ecx,%eax
c0100666:	39 c2                	cmp    %eax,%edx
c0100668:	73 22                	jae    c010068c <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010066a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010066d:	89 c2                	mov    %eax,%edx
c010066f:	89 d0                	mov    %edx,%eax
c0100671:	01 c0                	add    %eax,%eax
c0100673:	01 d0                	add    %edx,%eax
c0100675:	c1 e0 02             	shl    $0x2,%eax
c0100678:	89 c2                	mov    %eax,%edx
c010067a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010067d:	01 d0                	add    %edx,%eax
c010067f:	8b 10                	mov    (%eax),%edx
c0100681:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100684:	01 c2                	add    %eax,%edx
c0100686:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100689:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010068c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010068f:	89 c2                	mov    %eax,%edx
c0100691:	89 d0                	mov    %edx,%eax
c0100693:	01 c0                	add    %eax,%eax
c0100695:	01 d0                	add    %edx,%eax
c0100697:	c1 e0 02             	shl    $0x2,%eax
c010069a:	89 c2                	mov    %eax,%edx
c010069c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010069f:	01 d0                	add    %edx,%eax
c01006a1:	8b 50 08             	mov    0x8(%eax),%edx
c01006a4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006a7:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006ad:	8b 40 10             	mov    0x10(%eax),%eax
c01006b0:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006bf:	eb 15                	jmp    c01006d6 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006c4:	8b 55 08             	mov    0x8(%ebp),%edx
c01006c7:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006d9:	8b 40 08             	mov    0x8(%eax),%eax
c01006dc:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01006e3:	00 
c01006e4:	89 04 24             	mov    %eax,(%esp)
c01006e7:	e8 bc 54 00 00       	call   c0105ba8 <strfind>
c01006ec:	89 c2                	mov    %eax,%edx
c01006ee:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006f1:	8b 40 08             	mov    0x8(%eax),%eax
c01006f4:	29 c2                	sub    %eax,%edx
c01006f6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006f9:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01006fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01006ff:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100703:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c010070a:	00 
c010070b:	8d 45 d0             	lea    -0x30(%ebp),%eax
c010070e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100712:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100715:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100719:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010071c:	89 04 24             	mov    %eax,(%esp)
c010071f:	e8 b9 fc ff ff       	call   c01003dd <stab_binsearch>
    if (lline <= rline) {
c0100724:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100727:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010072a:	39 c2                	cmp    %eax,%edx
c010072c:	7f 24                	jg     c0100752 <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c010072e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100731:	89 c2                	mov    %eax,%edx
c0100733:	89 d0                	mov    %edx,%eax
c0100735:	01 c0                	add    %eax,%eax
c0100737:	01 d0                	add    %edx,%eax
c0100739:	c1 e0 02             	shl    $0x2,%eax
c010073c:	89 c2                	mov    %eax,%edx
c010073e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100741:	01 d0                	add    %edx,%eax
c0100743:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100747:	0f b7 d0             	movzwl %ax,%edx
c010074a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010074d:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100750:	eb 13                	jmp    c0100765 <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c0100752:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100757:	e9 12 01 00 00       	jmp    c010086e <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010075c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010075f:	83 e8 01             	sub    $0x1,%eax
c0100762:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100765:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100768:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010076b:	39 c2                	cmp    %eax,%edx
c010076d:	7c 56                	jl     c01007c5 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c010076f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100772:	89 c2                	mov    %eax,%edx
c0100774:	89 d0                	mov    %edx,%eax
c0100776:	01 c0                	add    %eax,%eax
c0100778:	01 d0                	add    %edx,%eax
c010077a:	c1 e0 02             	shl    $0x2,%eax
c010077d:	89 c2                	mov    %eax,%edx
c010077f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100782:	01 d0                	add    %edx,%eax
c0100784:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100788:	3c 84                	cmp    $0x84,%al
c010078a:	74 39                	je     c01007c5 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010078c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010078f:	89 c2                	mov    %eax,%edx
c0100791:	89 d0                	mov    %edx,%eax
c0100793:	01 c0                	add    %eax,%eax
c0100795:	01 d0                	add    %edx,%eax
c0100797:	c1 e0 02             	shl    $0x2,%eax
c010079a:	89 c2                	mov    %eax,%edx
c010079c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010079f:	01 d0                	add    %edx,%eax
c01007a1:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007a5:	3c 64                	cmp    $0x64,%al
c01007a7:	75 b3                	jne    c010075c <debuginfo_eip+0x229>
c01007a9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007ac:	89 c2                	mov    %eax,%edx
c01007ae:	89 d0                	mov    %edx,%eax
c01007b0:	01 c0                	add    %eax,%eax
c01007b2:	01 d0                	add    %edx,%eax
c01007b4:	c1 e0 02             	shl    $0x2,%eax
c01007b7:	89 c2                	mov    %eax,%edx
c01007b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007bc:	01 d0                	add    %edx,%eax
c01007be:	8b 40 08             	mov    0x8(%eax),%eax
c01007c1:	85 c0                	test   %eax,%eax
c01007c3:	74 97                	je     c010075c <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007c5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007cb:	39 c2                	cmp    %eax,%edx
c01007cd:	7c 46                	jl     c0100815 <debuginfo_eip+0x2e2>
c01007cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007d2:	89 c2                	mov    %eax,%edx
c01007d4:	89 d0                	mov    %edx,%eax
c01007d6:	01 c0                	add    %eax,%eax
c01007d8:	01 d0                	add    %edx,%eax
c01007da:	c1 e0 02             	shl    $0x2,%eax
c01007dd:	89 c2                	mov    %eax,%edx
c01007df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007e2:	01 d0                	add    %edx,%eax
c01007e4:	8b 10                	mov    (%eax),%edx
c01007e6:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01007e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01007ec:	29 c1                	sub    %eax,%ecx
c01007ee:	89 c8                	mov    %ecx,%eax
c01007f0:	39 c2                	cmp    %eax,%edx
c01007f2:	73 21                	jae    c0100815 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01007f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007f7:	89 c2                	mov    %eax,%edx
c01007f9:	89 d0                	mov    %edx,%eax
c01007fb:	01 c0                	add    %eax,%eax
c01007fd:	01 d0                	add    %edx,%eax
c01007ff:	c1 e0 02             	shl    $0x2,%eax
c0100802:	89 c2                	mov    %eax,%edx
c0100804:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100807:	01 d0                	add    %edx,%eax
c0100809:	8b 10                	mov    (%eax),%edx
c010080b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010080e:	01 c2                	add    %eax,%edx
c0100810:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100813:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100815:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100818:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010081b:	39 c2                	cmp    %eax,%edx
c010081d:	7d 4a                	jge    c0100869 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c010081f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100822:	83 c0 01             	add    $0x1,%eax
c0100825:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100828:	eb 18                	jmp    c0100842 <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c010082a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010082d:	8b 40 14             	mov    0x14(%eax),%eax
c0100830:	8d 50 01             	lea    0x1(%eax),%edx
c0100833:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100836:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100839:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010083c:	83 c0 01             	add    $0x1,%eax
c010083f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100842:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100845:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100848:	39 c2                	cmp    %eax,%edx
c010084a:	7d 1d                	jge    c0100869 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010084c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010084f:	89 c2                	mov    %eax,%edx
c0100851:	89 d0                	mov    %edx,%eax
c0100853:	01 c0                	add    %eax,%eax
c0100855:	01 d0                	add    %edx,%eax
c0100857:	c1 e0 02             	shl    $0x2,%eax
c010085a:	89 c2                	mov    %eax,%edx
c010085c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010085f:	01 d0                	add    %edx,%eax
c0100861:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100865:	3c a0                	cmp    $0xa0,%al
c0100867:	74 c1                	je     c010082a <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100869:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010086e:	c9                   	leave  
c010086f:	c3                   	ret    

c0100870 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100870:	55                   	push   %ebp
c0100871:	89 e5                	mov    %esp,%ebp
c0100873:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100876:	c7 04 24 76 5f 10 c0 	movl   $0xc0105f76,(%esp)
c010087d:	e8 ba fa ff ff       	call   c010033c <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100882:	c7 44 24 04 2a 00 10 	movl   $0xc010002a,0x4(%esp)
c0100889:	c0 
c010088a:	c7 04 24 8f 5f 10 c0 	movl   $0xc0105f8f,(%esp)
c0100891:	e8 a6 fa ff ff       	call   c010033c <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c0100896:	c7 44 24 04 bd 5e 10 	movl   $0xc0105ebd,0x4(%esp)
c010089d:	c0 
c010089e:	c7 04 24 a7 5f 10 c0 	movl   $0xc0105fa7,(%esp)
c01008a5:	e8 92 fa ff ff       	call   c010033c <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008aa:	c7 44 24 04 36 7a 11 	movl   $0xc0117a36,0x4(%esp)
c01008b1:	c0 
c01008b2:	c7 04 24 bf 5f 10 c0 	movl   $0xc0105fbf,(%esp)
c01008b9:	e8 7e fa ff ff       	call   c010033c <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008be:	c7 44 24 04 68 89 11 	movl   $0xc0118968,0x4(%esp)
c01008c5:	c0 
c01008c6:	c7 04 24 d7 5f 10 c0 	movl   $0xc0105fd7,(%esp)
c01008cd:	e8 6a fa ff ff       	call   c010033c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008d2:	b8 68 89 11 c0       	mov    $0xc0118968,%eax
c01008d7:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008dd:	b8 2a 00 10 c0       	mov    $0xc010002a,%eax
c01008e2:	29 c2                	sub    %eax,%edx
c01008e4:	89 d0                	mov    %edx,%eax
c01008e6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008ec:	85 c0                	test   %eax,%eax
c01008ee:	0f 48 c2             	cmovs  %edx,%eax
c01008f1:	c1 f8 0a             	sar    $0xa,%eax
c01008f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01008f8:	c7 04 24 f0 5f 10 c0 	movl   $0xc0105ff0,(%esp)
c01008ff:	e8 38 fa ff ff       	call   c010033c <cprintf>
}
c0100904:	c9                   	leave  
c0100905:	c3                   	ret    

c0100906 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100906:	55                   	push   %ebp
c0100907:	89 e5                	mov    %esp,%ebp
c0100909:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c010090f:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100912:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100916:	8b 45 08             	mov    0x8(%ebp),%eax
c0100919:	89 04 24             	mov    %eax,(%esp)
c010091c:	e8 12 fc ff ff       	call   c0100533 <debuginfo_eip>
c0100921:	85 c0                	test   %eax,%eax
c0100923:	74 15                	je     c010093a <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100925:	8b 45 08             	mov    0x8(%ebp),%eax
c0100928:	89 44 24 04          	mov    %eax,0x4(%esp)
c010092c:	c7 04 24 1a 60 10 c0 	movl   $0xc010601a,(%esp)
c0100933:	e8 04 fa ff ff       	call   c010033c <cprintf>
c0100938:	eb 6d                	jmp    c01009a7 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c010093a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100941:	eb 1c                	jmp    c010095f <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c0100943:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100946:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100949:	01 d0                	add    %edx,%eax
c010094b:	0f b6 00             	movzbl (%eax),%eax
c010094e:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100954:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100957:	01 ca                	add    %ecx,%edx
c0100959:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c010095b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010095f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100962:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100965:	7f dc                	jg     c0100943 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100967:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c010096d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100970:	01 d0                	add    %edx,%eax
c0100972:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100975:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100978:	8b 55 08             	mov    0x8(%ebp),%edx
c010097b:	89 d1                	mov    %edx,%ecx
c010097d:	29 c1                	sub    %eax,%ecx
c010097f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100982:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100985:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100989:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010098f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100993:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100997:	89 44 24 04          	mov    %eax,0x4(%esp)
c010099b:	c7 04 24 36 60 10 c0 	movl   $0xc0106036,(%esp)
c01009a2:	e8 95 f9 ff ff       	call   c010033c <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c01009a7:	c9                   	leave  
c01009a8:	c3                   	ret    

c01009a9 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009a9:	55                   	push   %ebp
c01009aa:	89 e5                	mov    %esp,%ebp
c01009ac:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009af:	8b 45 04             	mov    0x4(%ebp),%eax
c01009b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009b8:	c9                   	leave  
c01009b9:	c3                   	ret    

c01009ba <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009ba:	55                   	push   %ebp
c01009bb:	89 e5                	mov    %esp,%ebp
c01009bd:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009c0:	89 e8                	mov    %ebp,%eax
c01009c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c01009c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c01009c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01009cb:	e8 d9 ff ff ff       	call   c01009a9 <read_eip>
c01009d0:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c01009d3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01009da:	e9 88 00 00 00       	jmp    c0100a67 <print_stackframe+0xad>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c01009df:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009e2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01009e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009e9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009ed:	c7 04 24 48 60 10 c0 	movl   $0xc0106048,(%esp)
c01009f4:	e8 43 f9 ff ff       	call   c010033c <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
c01009f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009fc:	83 c0 08             	add    $0x8,%eax
c01009ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0100a02:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100a09:	eb 25                	jmp    c0100a30 <print_stackframe+0x76>
            cprintf("0x%08x ", args[j]);
c0100a0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a0e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100a18:	01 d0                	add    %edx,%eax
c0100a1a:	8b 00                	mov    (%eax),%eax
c0100a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a20:	c7 04 24 64 60 10 c0 	movl   $0xc0106064,(%esp)
c0100a27:	e8 10 f9 ff ff       	call   c010033c <cprintf>

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
c0100a2c:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0100a30:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100a34:	7e d5                	jle    c0100a0b <print_stackframe+0x51>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
c0100a36:	c7 04 24 6c 60 10 c0 	movl   $0xc010606c,(%esp)
c0100a3d:	e8 fa f8 ff ff       	call   c010033c <cprintf>
        print_debuginfo(eip - 1);
c0100a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a45:	83 e8 01             	sub    $0x1,%eax
c0100a48:	89 04 24             	mov    %eax,(%esp)
c0100a4b:	e8 b6 fe ff ff       	call   c0100906 <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0100a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a53:	83 c0 04             	add    $0x4,%eax
c0100a56:	8b 00                	mov    (%eax),%eax
c0100a58:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a5e:	8b 00                	mov    (%eax),%eax
c0100a60:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100a63:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100a67:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100a6b:	74 0a                	je     c0100a77 <print_stackframe+0xbd>
c0100a6d:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100a71:	0f 8e 68 ff ff ff    	jle    c01009df <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip - 1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
c0100a77:	c9                   	leave  
c0100a78:	c3                   	ret    

c0100a79 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100a79:	55                   	push   %ebp
c0100a7a:	89 e5                	mov    %esp,%ebp
c0100a7c:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100a7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a86:	eb 0c                	jmp    c0100a94 <parse+0x1b>
            *buf ++ = '\0';
c0100a88:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a8b:	8d 50 01             	lea    0x1(%eax),%edx
c0100a8e:	89 55 08             	mov    %edx,0x8(%ebp)
c0100a91:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a94:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a97:	0f b6 00             	movzbl (%eax),%eax
c0100a9a:	84 c0                	test   %al,%al
c0100a9c:	74 1d                	je     c0100abb <parse+0x42>
c0100a9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aa1:	0f b6 00             	movzbl (%eax),%eax
c0100aa4:	0f be c0             	movsbl %al,%eax
c0100aa7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100aab:	c7 04 24 f0 60 10 c0 	movl   $0xc01060f0,(%esp)
c0100ab2:	e8 be 50 00 00       	call   c0105b75 <strchr>
c0100ab7:	85 c0                	test   %eax,%eax
c0100ab9:	75 cd                	jne    c0100a88 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100abb:	8b 45 08             	mov    0x8(%ebp),%eax
c0100abe:	0f b6 00             	movzbl (%eax),%eax
c0100ac1:	84 c0                	test   %al,%al
c0100ac3:	75 02                	jne    c0100ac7 <parse+0x4e>
            break;
c0100ac5:	eb 67                	jmp    c0100b2e <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100ac7:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100acb:	75 14                	jne    c0100ae1 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100acd:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100ad4:	00 
c0100ad5:	c7 04 24 f5 60 10 c0 	movl   $0xc01060f5,(%esp)
c0100adc:	e8 5b f8 ff ff       	call   c010033c <cprintf>
        }
        argv[argc ++] = buf;
c0100ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ae4:	8d 50 01             	lea    0x1(%eax),%edx
c0100ae7:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100aea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100af1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100af4:	01 c2                	add    %eax,%edx
c0100af6:	8b 45 08             	mov    0x8(%ebp),%eax
c0100af9:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100afb:	eb 04                	jmp    c0100b01 <parse+0x88>
            buf ++;
c0100afd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b01:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b04:	0f b6 00             	movzbl (%eax),%eax
c0100b07:	84 c0                	test   %al,%al
c0100b09:	74 1d                	je     c0100b28 <parse+0xaf>
c0100b0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b0e:	0f b6 00             	movzbl (%eax),%eax
c0100b11:	0f be c0             	movsbl %al,%eax
c0100b14:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b18:	c7 04 24 f0 60 10 c0 	movl   $0xc01060f0,(%esp)
c0100b1f:	e8 51 50 00 00       	call   c0105b75 <strchr>
c0100b24:	85 c0                	test   %eax,%eax
c0100b26:	74 d5                	je     c0100afd <parse+0x84>
            buf ++;
        }
    }
c0100b28:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b29:	e9 66 ff ff ff       	jmp    c0100a94 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b31:	c9                   	leave  
c0100b32:	c3                   	ret    

c0100b33 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b33:	55                   	push   %ebp
c0100b34:	89 e5                	mov    %esp,%ebp
c0100b36:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b39:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b40:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b43:	89 04 24             	mov    %eax,(%esp)
c0100b46:	e8 2e ff ff ff       	call   c0100a79 <parse>
c0100b4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b4e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b52:	75 0a                	jne    c0100b5e <runcmd+0x2b>
        return 0;
c0100b54:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b59:	e9 85 00 00 00       	jmp    c0100be3 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b65:	eb 5c                	jmp    c0100bc3 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b67:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100b6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b6d:	89 d0                	mov    %edx,%eax
c0100b6f:	01 c0                	add    %eax,%eax
c0100b71:	01 d0                	add    %edx,%eax
c0100b73:	c1 e0 02             	shl    $0x2,%eax
c0100b76:	05 20 70 11 c0       	add    $0xc0117020,%eax
c0100b7b:	8b 00                	mov    (%eax),%eax
c0100b7d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100b81:	89 04 24             	mov    %eax,(%esp)
c0100b84:	e8 4d 4f 00 00       	call   c0105ad6 <strcmp>
c0100b89:	85 c0                	test   %eax,%eax
c0100b8b:	75 32                	jne    c0100bbf <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100b8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b90:	89 d0                	mov    %edx,%eax
c0100b92:	01 c0                	add    %eax,%eax
c0100b94:	01 d0                	add    %edx,%eax
c0100b96:	c1 e0 02             	shl    $0x2,%eax
c0100b99:	05 20 70 11 c0       	add    $0xc0117020,%eax
c0100b9e:	8b 40 08             	mov    0x8(%eax),%eax
c0100ba1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100ba4:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100ba7:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100baa:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100bae:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100bb1:	83 c2 04             	add    $0x4,%edx
c0100bb4:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100bb8:	89 0c 24             	mov    %ecx,(%esp)
c0100bbb:	ff d0                	call   *%eax
c0100bbd:	eb 24                	jmp    c0100be3 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bbf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bc6:	83 f8 02             	cmp    $0x2,%eax
c0100bc9:	76 9c                	jbe    c0100b67 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100bcb:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100bce:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bd2:	c7 04 24 13 61 10 c0 	movl   $0xc0106113,(%esp)
c0100bd9:	e8 5e f7 ff ff       	call   c010033c <cprintf>
    return 0;
c0100bde:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100be3:	c9                   	leave  
c0100be4:	c3                   	ret    

c0100be5 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100be5:	55                   	push   %ebp
c0100be6:	89 e5                	mov    %esp,%ebp
c0100be8:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100beb:	c7 04 24 2c 61 10 c0 	movl   $0xc010612c,(%esp)
c0100bf2:	e8 45 f7 ff ff       	call   c010033c <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100bf7:	c7 04 24 54 61 10 c0 	movl   $0xc0106154,(%esp)
c0100bfe:	e8 39 f7 ff ff       	call   c010033c <cprintf>

    if (tf != NULL) {
c0100c03:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c07:	74 0b                	je     c0100c14 <kmonitor+0x2f>
        print_trapframe(tf);
c0100c09:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c0c:	89 04 24             	mov    %eax,(%esp)
c0100c0f:	e8 b1 0d 00 00       	call   c01019c5 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c14:	c7 04 24 79 61 10 c0 	movl   $0xc0106179,(%esp)
c0100c1b:	e8 13 f6 ff ff       	call   c0100233 <readline>
c0100c20:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c23:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c27:	74 18                	je     c0100c41 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100c29:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c33:	89 04 24             	mov    %eax,(%esp)
c0100c36:	e8 f8 fe ff ff       	call   c0100b33 <runcmd>
c0100c3b:	85 c0                	test   %eax,%eax
c0100c3d:	79 02                	jns    c0100c41 <kmonitor+0x5c>
                break;
c0100c3f:	eb 02                	jmp    c0100c43 <kmonitor+0x5e>
            }
        }
    }
c0100c41:	eb d1                	jmp    c0100c14 <kmonitor+0x2f>
}
c0100c43:	c9                   	leave  
c0100c44:	c3                   	ret    

c0100c45 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c45:	55                   	push   %ebp
c0100c46:	89 e5                	mov    %esp,%ebp
c0100c48:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c4b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c52:	eb 3f                	jmp    c0100c93 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c54:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c57:	89 d0                	mov    %edx,%eax
c0100c59:	01 c0                	add    %eax,%eax
c0100c5b:	01 d0                	add    %edx,%eax
c0100c5d:	c1 e0 02             	shl    $0x2,%eax
c0100c60:	05 20 70 11 c0       	add    $0xc0117020,%eax
c0100c65:	8b 48 04             	mov    0x4(%eax),%ecx
c0100c68:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c6b:	89 d0                	mov    %edx,%eax
c0100c6d:	01 c0                	add    %eax,%eax
c0100c6f:	01 d0                	add    %edx,%eax
c0100c71:	c1 e0 02             	shl    $0x2,%eax
c0100c74:	05 20 70 11 c0       	add    $0xc0117020,%eax
c0100c79:	8b 00                	mov    (%eax),%eax
c0100c7b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c7f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c83:	c7 04 24 7d 61 10 c0 	movl   $0xc010617d,(%esp)
c0100c8a:	e8 ad f6 ff ff       	call   c010033c <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c8f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c96:	83 f8 02             	cmp    $0x2,%eax
c0100c99:	76 b9                	jbe    c0100c54 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100c9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ca0:	c9                   	leave  
c0100ca1:	c3                   	ret    

c0100ca2 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100ca2:	55                   	push   %ebp
c0100ca3:	89 e5                	mov    %esp,%ebp
c0100ca5:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100ca8:	e8 c3 fb ff ff       	call   c0100870 <print_kerninfo>
    return 0;
c0100cad:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cb2:	c9                   	leave  
c0100cb3:	c3                   	ret    

c0100cb4 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100cb4:	55                   	push   %ebp
c0100cb5:	89 e5                	mov    %esp,%ebp
c0100cb7:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100cba:	e8 fb fc ff ff       	call   c01009ba <print_stackframe>
    return 0;
c0100cbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cc4:	c9                   	leave  
c0100cc5:	c3                   	ret    

c0100cc6 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100cc6:	55                   	push   %ebp
c0100cc7:	89 e5                	mov    %esp,%ebp
c0100cc9:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100ccc:	a1 60 7e 11 c0       	mov    0xc0117e60,%eax
c0100cd1:	85 c0                	test   %eax,%eax
c0100cd3:	74 02                	je     c0100cd7 <__panic+0x11>
        goto panic_dead;
c0100cd5:	eb 48                	jmp    c0100d1f <__panic+0x59>
    }
    is_panic = 1;
c0100cd7:	c7 05 60 7e 11 c0 01 	movl   $0x1,0xc0117e60
c0100cde:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100ce1:	8d 45 14             	lea    0x14(%ebp),%eax
c0100ce4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100ce7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100cea:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100cee:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cf1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cf5:	c7 04 24 86 61 10 c0 	movl   $0xc0106186,(%esp)
c0100cfc:	e8 3b f6 ff ff       	call   c010033c <cprintf>
    vcprintf(fmt, ap);
c0100d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d08:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d0b:	89 04 24             	mov    %eax,(%esp)
c0100d0e:	e8 f6 f5 ff ff       	call   c0100309 <vcprintf>
    cprintf("\n");
c0100d13:	c7 04 24 a2 61 10 c0 	movl   $0xc01061a2,(%esp)
c0100d1a:	e8 1d f6 ff ff       	call   c010033c <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
c0100d1f:	e8 85 09 00 00       	call   c01016a9 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d2b:	e8 b5 fe ff ff       	call   c0100be5 <kmonitor>
    }
c0100d30:	eb f2                	jmp    c0100d24 <__panic+0x5e>

c0100d32 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d32:	55                   	push   %ebp
c0100d33:	89 e5                	mov    %esp,%ebp
c0100d35:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d38:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d3e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d41:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d45:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d4c:	c7 04 24 a4 61 10 c0 	movl   $0xc01061a4,(%esp)
c0100d53:	e8 e4 f5 ff ff       	call   c010033c <cprintf>
    vcprintf(fmt, ap);
c0100d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d5b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d5f:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d62:	89 04 24             	mov    %eax,(%esp)
c0100d65:	e8 9f f5 ff ff       	call   c0100309 <vcprintf>
    cprintf("\n");
c0100d6a:	c7 04 24 a2 61 10 c0 	movl   $0xc01061a2,(%esp)
c0100d71:	e8 c6 f5 ff ff       	call   c010033c <cprintf>
    va_end(ap);
}
c0100d76:	c9                   	leave  
c0100d77:	c3                   	ret    

c0100d78 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100d78:	55                   	push   %ebp
c0100d79:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100d7b:	a1 60 7e 11 c0       	mov    0xc0117e60,%eax
}
c0100d80:	5d                   	pop    %ebp
c0100d81:	c3                   	ret    

c0100d82 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100d82:	55                   	push   %ebp
c0100d83:	89 e5                	mov    %esp,%ebp
c0100d85:	83 ec 28             	sub    $0x28,%esp
c0100d88:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100d8e:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100d92:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100d96:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100d9a:	ee                   	out    %al,(%dx)
c0100d9b:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100da1:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100da5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100da9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100dad:	ee                   	out    %al,(%dx)
c0100dae:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100db4:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100db8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100dbc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100dc0:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100dc1:	c7 05 4c 89 11 c0 00 	movl   $0x0,0xc011894c
c0100dc8:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100dcb:	c7 04 24 c2 61 10 c0 	movl   $0xc01061c2,(%esp)
c0100dd2:	e8 65 f5 ff ff       	call   c010033c <cprintf>
    pic_enable(IRQ_TIMER);
c0100dd7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100dde:	e8 24 09 00 00       	call   c0101707 <pic_enable>
}
c0100de3:	c9                   	leave  
c0100de4:	c3                   	ret    

c0100de5 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100de5:	55                   	push   %ebp
c0100de6:	89 e5                	mov    %esp,%ebp
c0100de8:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100deb:	9c                   	pushf  
c0100dec:	58                   	pop    %eax
c0100ded:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100df3:	25 00 02 00 00       	and    $0x200,%eax
c0100df8:	85 c0                	test   %eax,%eax
c0100dfa:	74 0c                	je     c0100e08 <__intr_save+0x23>
        intr_disable();
c0100dfc:	e8 a8 08 00 00       	call   c01016a9 <intr_disable>
        return 1;
c0100e01:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e06:	eb 05                	jmp    c0100e0d <__intr_save+0x28>
    }
    return 0;
c0100e08:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e0d:	c9                   	leave  
c0100e0e:	c3                   	ret    

c0100e0f <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e0f:	55                   	push   %ebp
c0100e10:	89 e5                	mov    %esp,%ebp
c0100e12:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e15:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e19:	74 05                	je     c0100e20 <__intr_restore+0x11>
        intr_enable();
c0100e1b:	e8 83 08 00 00       	call   c01016a3 <intr_enable>
    }
}
c0100e20:	c9                   	leave  
c0100e21:	c3                   	ret    

c0100e22 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e22:	55                   	push   %ebp
c0100e23:	89 e5                	mov    %esp,%ebp
c0100e25:	83 ec 10             	sub    $0x10,%esp
c0100e28:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e2e:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e32:	89 c2                	mov    %eax,%edx
c0100e34:	ec                   	in     (%dx),%al
c0100e35:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100e38:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e3e:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e42:	89 c2                	mov    %eax,%edx
c0100e44:	ec                   	in     (%dx),%al
c0100e45:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e48:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e4e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e52:	89 c2                	mov    %eax,%edx
c0100e54:	ec                   	in     (%dx),%al
c0100e55:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e58:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100e5e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e62:	89 c2                	mov    %eax,%edx
c0100e64:	ec                   	in     (%dx),%al
c0100e65:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e68:	c9                   	leave  
c0100e69:	c3                   	ret    

c0100e6a <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e6a:	55                   	push   %ebp
c0100e6b:	89 e5                	mov    %esp,%ebp
c0100e6d:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e70:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100e77:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e7a:	0f b7 00             	movzwl (%eax),%eax
c0100e7d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100e81:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e84:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100e89:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e8c:	0f b7 00             	movzwl (%eax),%eax
c0100e8f:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100e93:	74 12                	je     c0100ea7 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100e95:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100e9c:	66 c7 05 86 7e 11 c0 	movw   $0x3b4,0xc0117e86
c0100ea3:	b4 03 
c0100ea5:	eb 13                	jmp    c0100eba <cga_init+0x50>
    } else {
        *cp = was;
c0100ea7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eaa:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100eae:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100eb1:	66 c7 05 86 7e 11 c0 	movw   $0x3d4,0xc0117e86
c0100eb8:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100eba:	0f b7 05 86 7e 11 c0 	movzwl 0xc0117e86,%eax
c0100ec1:	0f b7 c0             	movzwl %ax,%eax
c0100ec4:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100ec8:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ecc:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100ed0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100ed4:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100ed5:	0f b7 05 86 7e 11 c0 	movzwl 0xc0117e86,%eax
c0100edc:	83 c0 01             	add    $0x1,%eax
c0100edf:	0f b7 c0             	movzwl %ax,%eax
c0100ee2:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ee6:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100eea:	89 c2                	mov    %eax,%edx
c0100eec:	ec                   	in     (%dx),%al
c0100eed:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100ef0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100ef4:	0f b6 c0             	movzbl %al,%eax
c0100ef7:	c1 e0 08             	shl    $0x8,%eax
c0100efa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100efd:	0f b7 05 86 7e 11 c0 	movzwl 0xc0117e86,%eax
c0100f04:	0f b7 c0             	movzwl %ax,%eax
c0100f07:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0100f0b:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f0f:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f13:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f17:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f18:	0f b7 05 86 7e 11 c0 	movzwl 0xc0117e86,%eax
c0100f1f:	83 c0 01             	add    $0x1,%eax
c0100f22:	0f b7 c0             	movzwl %ax,%eax
c0100f25:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f29:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0100f2d:	89 c2                	mov    %eax,%edx
c0100f2f:	ec                   	in     (%dx),%al
c0100f30:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0100f33:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f37:	0f b6 c0             	movzbl %al,%eax
c0100f3a:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f40:	a3 80 7e 11 c0       	mov    %eax,0xc0117e80
    crt_pos = pos;
c0100f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f48:	66 a3 84 7e 11 c0    	mov    %ax,0xc0117e84
}
c0100f4e:	c9                   	leave  
c0100f4f:	c3                   	ret    

c0100f50 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f50:	55                   	push   %ebp
c0100f51:	89 e5                	mov    %esp,%ebp
c0100f53:	83 ec 48             	sub    $0x48,%esp
c0100f56:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f5c:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f60:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100f64:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f68:	ee                   	out    %al,(%dx)
c0100f69:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0100f6f:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0100f73:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f77:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100f7b:	ee                   	out    %al,(%dx)
c0100f7c:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0100f82:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0100f86:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f8a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f8e:	ee                   	out    %al,(%dx)
c0100f8f:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100f95:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0100f99:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f9d:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fa1:	ee                   	out    %al,(%dx)
c0100fa2:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0100fa8:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0100fac:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fb0:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100fb4:	ee                   	out    %al,(%dx)
c0100fb5:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0100fbb:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0100fbf:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100fc3:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100fc7:	ee                   	out    %al,(%dx)
c0100fc8:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100fce:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0100fd2:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100fd6:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100fda:	ee                   	out    %al,(%dx)
c0100fdb:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100fe1:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0100fe5:	89 c2                	mov    %eax,%edx
c0100fe7:	ec                   	in     (%dx),%al
c0100fe8:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0100feb:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0100fef:	3c ff                	cmp    $0xff,%al
c0100ff1:	0f 95 c0             	setne  %al
c0100ff4:	0f b6 c0             	movzbl %al,%eax
c0100ff7:	a3 88 7e 11 c0       	mov    %eax,0xc0117e88
c0100ffc:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101002:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c0101006:	89 c2                	mov    %eax,%edx
c0101008:	ec                   	in     (%dx),%al
c0101009:	88 45 d5             	mov    %al,-0x2b(%ebp)
c010100c:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c0101012:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0101016:	89 c2                	mov    %eax,%edx
c0101018:	ec                   	in     (%dx),%al
c0101019:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c010101c:	a1 88 7e 11 c0       	mov    0xc0117e88,%eax
c0101021:	85 c0                	test   %eax,%eax
c0101023:	74 0c                	je     c0101031 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0101025:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010102c:	e8 d6 06 00 00       	call   c0101707 <pic_enable>
    }
}
c0101031:	c9                   	leave  
c0101032:	c3                   	ret    

c0101033 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101033:	55                   	push   %ebp
c0101034:	89 e5                	mov    %esp,%ebp
c0101036:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101039:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101040:	eb 09                	jmp    c010104b <lpt_putc_sub+0x18>
        delay();
c0101042:	e8 db fd ff ff       	call   c0100e22 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101047:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010104b:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0101051:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101055:	89 c2                	mov    %eax,%edx
c0101057:	ec                   	in     (%dx),%al
c0101058:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010105b:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010105f:	84 c0                	test   %al,%al
c0101061:	78 09                	js     c010106c <lpt_putc_sub+0x39>
c0101063:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010106a:	7e d6                	jle    c0101042 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c010106c:	8b 45 08             	mov    0x8(%ebp),%eax
c010106f:	0f b6 c0             	movzbl %al,%eax
c0101072:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c0101078:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010107b:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010107f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101083:	ee                   	out    %al,(%dx)
c0101084:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c010108a:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c010108e:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101092:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101096:	ee                   	out    %al,(%dx)
c0101097:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c010109d:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01010a1:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010a5:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010a9:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010aa:	c9                   	leave  
c01010ab:	c3                   	ret    

c01010ac <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010ac:	55                   	push   %ebp
c01010ad:	89 e5                	mov    %esp,%ebp
c01010af:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010b2:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010b6:	74 0d                	je     c01010c5 <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01010bb:	89 04 24             	mov    %eax,(%esp)
c01010be:	e8 70 ff ff ff       	call   c0101033 <lpt_putc_sub>
c01010c3:	eb 24                	jmp    c01010e9 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c01010c5:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010cc:	e8 62 ff ff ff       	call   c0101033 <lpt_putc_sub>
        lpt_putc_sub(' ');
c01010d1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01010d8:	e8 56 ff ff ff       	call   c0101033 <lpt_putc_sub>
        lpt_putc_sub('\b');
c01010dd:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010e4:	e8 4a ff ff ff       	call   c0101033 <lpt_putc_sub>
    }
}
c01010e9:	c9                   	leave  
c01010ea:	c3                   	ret    

c01010eb <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c01010eb:	55                   	push   %ebp
c01010ec:	89 e5                	mov    %esp,%ebp
c01010ee:	53                   	push   %ebx
c01010ef:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c01010f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01010f5:	b0 00                	mov    $0x0,%al
c01010f7:	85 c0                	test   %eax,%eax
c01010f9:	75 07                	jne    c0101102 <cga_putc+0x17>
        c |= 0x0700;
c01010fb:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101102:	8b 45 08             	mov    0x8(%ebp),%eax
c0101105:	0f b6 c0             	movzbl %al,%eax
c0101108:	83 f8 0a             	cmp    $0xa,%eax
c010110b:	74 4c                	je     c0101159 <cga_putc+0x6e>
c010110d:	83 f8 0d             	cmp    $0xd,%eax
c0101110:	74 57                	je     c0101169 <cga_putc+0x7e>
c0101112:	83 f8 08             	cmp    $0x8,%eax
c0101115:	0f 85 88 00 00 00    	jne    c01011a3 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c010111b:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c0101122:	66 85 c0             	test   %ax,%ax
c0101125:	74 30                	je     c0101157 <cga_putc+0x6c>
            crt_pos --;
c0101127:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c010112e:	83 e8 01             	sub    $0x1,%eax
c0101131:	66 a3 84 7e 11 c0    	mov    %ax,0xc0117e84
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101137:	a1 80 7e 11 c0       	mov    0xc0117e80,%eax
c010113c:	0f b7 15 84 7e 11 c0 	movzwl 0xc0117e84,%edx
c0101143:	0f b7 d2             	movzwl %dx,%edx
c0101146:	01 d2                	add    %edx,%edx
c0101148:	01 c2                	add    %eax,%edx
c010114a:	8b 45 08             	mov    0x8(%ebp),%eax
c010114d:	b0 00                	mov    $0x0,%al
c010114f:	83 c8 20             	or     $0x20,%eax
c0101152:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101155:	eb 72                	jmp    c01011c9 <cga_putc+0xde>
c0101157:	eb 70                	jmp    c01011c9 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0101159:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c0101160:	83 c0 50             	add    $0x50,%eax
c0101163:	66 a3 84 7e 11 c0    	mov    %ax,0xc0117e84
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101169:	0f b7 1d 84 7e 11 c0 	movzwl 0xc0117e84,%ebx
c0101170:	0f b7 0d 84 7e 11 c0 	movzwl 0xc0117e84,%ecx
c0101177:	0f b7 c1             	movzwl %cx,%eax
c010117a:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c0101180:	c1 e8 10             	shr    $0x10,%eax
c0101183:	89 c2                	mov    %eax,%edx
c0101185:	66 c1 ea 06          	shr    $0x6,%dx
c0101189:	89 d0                	mov    %edx,%eax
c010118b:	c1 e0 02             	shl    $0x2,%eax
c010118e:	01 d0                	add    %edx,%eax
c0101190:	c1 e0 04             	shl    $0x4,%eax
c0101193:	29 c1                	sub    %eax,%ecx
c0101195:	89 ca                	mov    %ecx,%edx
c0101197:	89 d8                	mov    %ebx,%eax
c0101199:	29 d0                	sub    %edx,%eax
c010119b:	66 a3 84 7e 11 c0    	mov    %ax,0xc0117e84
        break;
c01011a1:	eb 26                	jmp    c01011c9 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011a3:	8b 0d 80 7e 11 c0    	mov    0xc0117e80,%ecx
c01011a9:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c01011b0:	8d 50 01             	lea    0x1(%eax),%edx
c01011b3:	66 89 15 84 7e 11 c0 	mov    %dx,0xc0117e84
c01011ba:	0f b7 c0             	movzwl %ax,%eax
c01011bd:	01 c0                	add    %eax,%eax
c01011bf:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01011c5:	66 89 02             	mov    %ax,(%edx)
        break;
c01011c8:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011c9:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c01011d0:	66 3d cf 07          	cmp    $0x7cf,%ax
c01011d4:	76 5b                	jbe    c0101231 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01011d6:	a1 80 7e 11 c0       	mov    0xc0117e80,%eax
c01011db:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01011e1:	a1 80 7e 11 c0       	mov    0xc0117e80,%eax
c01011e6:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c01011ed:	00 
c01011ee:	89 54 24 04          	mov    %edx,0x4(%esp)
c01011f2:	89 04 24             	mov    %eax,(%esp)
c01011f5:	e8 79 4b 00 00       	call   c0105d73 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01011fa:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101201:	eb 15                	jmp    c0101218 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c0101203:	a1 80 7e 11 c0       	mov    0xc0117e80,%eax
c0101208:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010120b:	01 d2                	add    %edx,%edx
c010120d:	01 d0                	add    %edx,%eax
c010120f:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101214:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101218:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010121f:	7e e2                	jle    c0101203 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101221:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c0101228:	83 e8 50             	sub    $0x50,%eax
c010122b:	66 a3 84 7e 11 c0    	mov    %ax,0xc0117e84
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101231:	0f b7 05 86 7e 11 c0 	movzwl 0xc0117e86,%eax
c0101238:	0f b7 c0             	movzwl %ax,%eax
c010123b:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010123f:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c0101243:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101247:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010124b:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c010124c:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c0101253:	66 c1 e8 08          	shr    $0x8,%ax
c0101257:	0f b6 c0             	movzbl %al,%eax
c010125a:	0f b7 15 86 7e 11 c0 	movzwl 0xc0117e86,%edx
c0101261:	83 c2 01             	add    $0x1,%edx
c0101264:	0f b7 d2             	movzwl %dx,%edx
c0101267:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c010126b:	88 45 ed             	mov    %al,-0x13(%ebp)
c010126e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101272:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101276:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101277:	0f b7 05 86 7e 11 c0 	movzwl 0xc0117e86,%eax
c010127e:	0f b7 c0             	movzwl %ax,%eax
c0101281:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0101285:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c0101289:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010128d:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101291:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0101292:	0f b7 05 84 7e 11 c0 	movzwl 0xc0117e84,%eax
c0101299:	0f b6 c0             	movzbl %al,%eax
c010129c:	0f b7 15 86 7e 11 c0 	movzwl 0xc0117e86,%edx
c01012a3:	83 c2 01             	add    $0x1,%edx
c01012a6:	0f b7 d2             	movzwl %dx,%edx
c01012a9:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012ad:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01012b0:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012b4:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012b8:	ee                   	out    %al,(%dx)
}
c01012b9:	83 c4 34             	add    $0x34,%esp
c01012bc:	5b                   	pop    %ebx
c01012bd:	5d                   	pop    %ebp
c01012be:	c3                   	ret    

c01012bf <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012bf:	55                   	push   %ebp
c01012c0:	89 e5                	mov    %esp,%ebp
c01012c2:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012cc:	eb 09                	jmp    c01012d7 <serial_putc_sub+0x18>
        delay();
c01012ce:	e8 4f fb ff ff       	call   c0100e22 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012d3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01012d7:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01012dd:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01012e1:	89 c2                	mov    %eax,%edx
c01012e3:	ec                   	in     (%dx),%al
c01012e4:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01012e7:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01012eb:	0f b6 c0             	movzbl %al,%eax
c01012ee:	83 e0 20             	and    $0x20,%eax
c01012f1:	85 c0                	test   %eax,%eax
c01012f3:	75 09                	jne    c01012fe <serial_putc_sub+0x3f>
c01012f5:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01012fc:	7e d0                	jle    c01012ce <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c01012fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0101301:	0f b6 c0             	movzbl %al,%eax
c0101304:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c010130a:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010130d:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101311:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101315:	ee                   	out    %al,(%dx)
}
c0101316:	c9                   	leave  
c0101317:	c3                   	ret    

c0101318 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101318:	55                   	push   %ebp
c0101319:	89 e5                	mov    %esp,%ebp
c010131b:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010131e:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101322:	74 0d                	je     c0101331 <serial_putc+0x19>
        serial_putc_sub(c);
c0101324:	8b 45 08             	mov    0x8(%ebp),%eax
c0101327:	89 04 24             	mov    %eax,(%esp)
c010132a:	e8 90 ff ff ff       	call   c01012bf <serial_putc_sub>
c010132f:	eb 24                	jmp    c0101355 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c0101331:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101338:	e8 82 ff ff ff       	call   c01012bf <serial_putc_sub>
        serial_putc_sub(' ');
c010133d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101344:	e8 76 ff ff ff       	call   c01012bf <serial_putc_sub>
        serial_putc_sub('\b');
c0101349:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101350:	e8 6a ff ff ff       	call   c01012bf <serial_putc_sub>
    }
}
c0101355:	c9                   	leave  
c0101356:	c3                   	ret    

c0101357 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101357:	55                   	push   %ebp
c0101358:	89 e5                	mov    %esp,%ebp
c010135a:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c010135d:	eb 33                	jmp    c0101392 <cons_intr+0x3b>
        if (c != 0) {
c010135f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101363:	74 2d                	je     c0101392 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101365:	a1 a4 80 11 c0       	mov    0xc01180a4,%eax
c010136a:	8d 50 01             	lea    0x1(%eax),%edx
c010136d:	89 15 a4 80 11 c0    	mov    %edx,0xc01180a4
c0101373:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101376:	88 90 a0 7e 11 c0    	mov    %dl,-0x3fee8160(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c010137c:	a1 a4 80 11 c0       	mov    0xc01180a4,%eax
c0101381:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101386:	75 0a                	jne    c0101392 <cons_intr+0x3b>
                cons.wpos = 0;
c0101388:	c7 05 a4 80 11 c0 00 	movl   $0x0,0xc01180a4
c010138f:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c0101392:	8b 45 08             	mov    0x8(%ebp),%eax
c0101395:	ff d0                	call   *%eax
c0101397:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010139a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c010139e:	75 bf                	jne    c010135f <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01013a0:	c9                   	leave  
c01013a1:	c3                   	ret    

c01013a2 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013a2:	55                   	push   %ebp
c01013a3:	89 e5                	mov    %esp,%ebp
c01013a5:	83 ec 10             	sub    $0x10,%esp
c01013a8:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013ae:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013b2:	89 c2                	mov    %eax,%edx
c01013b4:	ec                   	in     (%dx),%al
c01013b5:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013b8:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013bc:	0f b6 c0             	movzbl %al,%eax
c01013bf:	83 e0 01             	and    $0x1,%eax
c01013c2:	85 c0                	test   %eax,%eax
c01013c4:	75 07                	jne    c01013cd <serial_proc_data+0x2b>
        return -1;
c01013c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013cb:	eb 2a                	jmp    c01013f7 <serial_proc_data+0x55>
c01013cd:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013d3:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01013d7:	89 c2                	mov    %eax,%edx
c01013d9:	ec                   	in     (%dx),%al
c01013da:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c01013dd:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01013e1:	0f b6 c0             	movzbl %al,%eax
c01013e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c01013e7:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c01013eb:	75 07                	jne    c01013f4 <serial_proc_data+0x52>
        c = '\b';
c01013ed:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c01013f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01013f7:	c9                   	leave  
c01013f8:	c3                   	ret    

c01013f9 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c01013f9:	55                   	push   %ebp
c01013fa:	89 e5                	mov    %esp,%ebp
c01013fc:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c01013ff:	a1 88 7e 11 c0       	mov    0xc0117e88,%eax
c0101404:	85 c0                	test   %eax,%eax
c0101406:	74 0c                	je     c0101414 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101408:	c7 04 24 a2 13 10 c0 	movl   $0xc01013a2,(%esp)
c010140f:	e8 43 ff ff ff       	call   c0101357 <cons_intr>
    }
}
c0101414:	c9                   	leave  
c0101415:	c3                   	ret    

c0101416 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101416:	55                   	push   %ebp
c0101417:	89 e5                	mov    %esp,%ebp
c0101419:	83 ec 38             	sub    $0x38,%esp
c010141c:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101422:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101426:	89 c2                	mov    %eax,%edx
c0101428:	ec                   	in     (%dx),%al
c0101429:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c010142c:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101430:	0f b6 c0             	movzbl %al,%eax
c0101433:	83 e0 01             	and    $0x1,%eax
c0101436:	85 c0                	test   %eax,%eax
c0101438:	75 0a                	jne    c0101444 <kbd_proc_data+0x2e>
        return -1;
c010143a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010143f:	e9 59 01 00 00       	jmp    c010159d <kbd_proc_data+0x187>
c0101444:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010144a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010144e:	89 c2                	mov    %eax,%edx
c0101450:	ec                   	in     (%dx),%al
c0101451:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101454:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101458:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c010145b:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010145f:	75 17                	jne    c0101478 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0101461:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c0101466:	83 c8 40             	or     $0x40,%eax
c0101469:	a3 a8 80 11 c0       	mov    %eax,0xc01180a8
        return 0;
c010146e:	b8 00 00 00 00       	mov    $0x0,%eax
c0101473:	e9 25 01 00 00       	jmp    c010159d <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c0101478:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010147c:	84 c0                	test   %al,%al
c010147e:	79 47                	jns    c01014c7 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101480:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c0101485:	83 e0 40             	and    $0x40,%eax
c0101488:	85 c0                	test   %eax,%eax
c010148a:	75 09                	jne    c0101495 <kbd_proc_data+0x7f>
c010148c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101490:	83 e0 7f             	and    $0x7f,%eax
c0101493:	eb 04                	jmp    c0101499 <kbd_proc_data+0x83>
c0101495:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101499:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c010149c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014a0:	0f b6 80 60 70 11 c0 	movzbl -0x3fee8fa0(%eax),%eax
c01014a7:	83 c8 40             	or     $0x40,%eax
c01014aa:	0f b6 c0             	movzbl %al,%eax
c01014ad:	f7 d0                	not    %eax
c01014af:	89 c2                	mov    %eax,%edx
c01014b1:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c01014b6:	21 d0                	and    %edx,%eax
c01014b8:	a3 a8 80 11 c0       	mov    %eax,0xc01180a8
        return 0;
c01014bd:	b8 00 00 00 00       	mov    $0x0,%eax
c01014c2:	e9 d6 00 00 00       	jmp    c010159d <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01014c7:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c01014cc:	83 e0 40             	and    $0x40,%eax
c01014cf:	85 c0                	test   %eax,%eax
c01014d1:	74 11                	je     c01014e4 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014d3:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01014d7:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c01014dc:	83 e0 bf             	and    $0xffffffbf,%eax
c01014df:	a3 a8 80 11 c0       	mov    %eax,0xc01180a8
    }

    shift |= shiftcode[data];
c01014e4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014e8:	0f b6 80 60 70 11 c0 	movzbl -0x3fee8fa0(%eax),%eax
c01014ef:	0f b6 d0             	movzbl %al,%edx
c01014f2:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c01014f7:	09 d0                	or     %edx,%eax
c01014f9:	a3 a8 80 11 c0       	mov    %eax,0xc01180a8
    shift ^= togglecode[data];
c01014fe:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101502:	0f b6 80 60 71 11 c0 	movzbl -0x3fee8ea0(%eax),%eax
c0101509:	0f b6 d0             	movzbl %al,%edx
c010150c:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c0101511:	31 d0                	xor    %edx,%eax
c0101513:	a3 a8 80 11 c0       	mov    %eax,0xc01180a8

    c = charcode[shift & (CTL | SHIFT)][data];
c0101518:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c010151d:	83 e0 03             	and    $0x3,%eax
c0101520:	8b 14 85 60 75 11 c0 	mov    -0x3fee8aa0(,%eax,4),%edx
c0101527:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010152b:	01 d0                	add    %edx,%eax
c010152d:	0f b6 00             	movzbl (%eax),%eax
c0101530:	0f b6 c0             	movzbl %al,%eax
c0101533:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101536:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c010153b:	83 e0 08             	and    $0x8,%eax
c010153e:	85 c0                	test   %eax,%eax
c0101540:	74 22                	je     c0101564 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101542:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101546:	7e 0c                	jle    c0101554 <kbd_proc_data+0x13e>
c0101548:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c010154c:	7f 06                	jg     c0101554 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c010154e:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101552:	eb 10                	jmp    c0101564 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101554:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101558:	7e 0a                	jle    c0101564 <kbd_proc_data+0x14e>
c010155a:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c010155e:	7f 04                	jg     c0101564 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101560:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101564:	a1 a8 80 11 c0       	mov    0xc01180a8,%eax
c0101569:	f7 d0                	not    %eax
c010156b:	83 e0 06             	and    $0x6,%eax
c010156e:	85 c0                	test   %eax,%eax
c0101570:	75 28                	jne    c010159a <kbd_proc_data+0x184>
c0101572:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101579:	75 1f                	jne    c010159a <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c010157b:	c7 04 24 dd 61 10 c0 	movl   $0xc01061dd,(%esp)
c0101582:	e8 b5 ed ff ff       	call   c010033c <cprintf>
c0101587:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c010158d:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101591:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101595:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c0101599:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c010159a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010159d:	c9                   	leave  
c010159e:	c3                   	ret    

c010159f <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c010159f:	55                   	push   %ebp
c01015a0:	89 e5                	mov    %esp,%ebp
c01015a2:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015a5:	c7 04 24 16 14 10 c0 	movl   $0xc0101416,(%esp)
c01015ac:	e8 a6 fd ff ff       	call   c0101357 <cons_intr>
}
c01015b1:	c9                   	leave  
c01015b2:	c3                   	ret    

c01015b3 <kbd_init>:

static void
kbd_init(void) {
c01015b3:	55                   	push   %ebp
c01015b4:	89 e5                	mov    %esp,%ebp
c01015b6:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015b9:	e8 e1 ff ff ff       	call   c010159f <kbd_intr>
    pic_enable(IRQ_KBD);
c01015be:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015c5:	e8 3d 01 00 00       	call   c0101707 <pic_enable>
}
c01015ca:	c9                   	leave  
c01015cb:	c3                   	ret    

c01015cc <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015cc:	55                   	push   %ebp
c01015cd:	89 e5                	mov    %esp,%ebp
c01015cf:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01015d2:	e8 93 f8 ff ff       	call   c0100e6a <cga_init>
    serial_init();
c01015d7:	e8 74 f9 ff ff       	call   c0100f50 <serial_init>
    kbd_init();
c01015dc:	e8 d2 ff ff ff       	call   c01015b3 <kbd_init>
    if (!serial_exists) {
c01015e1:	a1 88 7e 11 c0       	mov    0xc0117e88,%eax
c01015e6:	85 c0                	test   %eax,%eax
c01015e8:	75 0c                	jne    c01015f6 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c01015ea:	c7 04 24 e9 61 10 c0 	movl   $0xc01061e9,(%esp)
c01015f1:	e8 46 ed ff ff       	call   c010033c <cprintf>
    }
}
c01015f6:	c9                   	leave  
c01015f7:	c3                   	ret    

c01015f8 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c01015f8:	55                   	push   %ebp
c01015f9:	89 e5                	mov    %esp,%ebp
c01015fb:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01015fe:	e8 e2 f7 ff ff       	call   c0100de5 <__intr_save>
c0101603:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101606:	8b 45 08             	mov    0x8(%ebp),%eax
c0101609:	89 04 24             	mov    %eax,(%esp)
c010160c:	e8 9b fa ff ff       	call   c01010ac <lpt_putc>
        cga_putc(c);
c0101611:	8b 45 08             	mov    0x8(%ebp),%eax
c0101614:	89 04 24             	mov    %eax,(%esp)
c0101617:	e8 cf fa ff ff       	call   c01010eb <cga_putc>
        serial_putc(c);
c010161c:	8b 45 08             	mov    0x8(%ebp),%eax
c010161f:	89 04 24             	mov    %eax,(%esp)
c0101622:	e8 f1 fc ff ff       	call   c0101318 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101627:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010162a:	89 04 24             	mov    %eax,(%esp)
c010162d:	e8 dd f7 ff ff       	call   c0100e0f <__intr_restore>
}
c0101632:	c9                   	leave  
c0101633:	c3                   	ret    

c0101634 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101634:	55                   	push   %ebp
c0101635:	89 e5                	mov    %esp,%ebp
c0101637:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c010163a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101641:	e8 9f f7 ff ff       	call   c0100de5 <__intr_save>
c0101646:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101649:	e8 ab fd ff ff       	call   c01013f9 <serial_intr>
        kbd_intr();
c010164e:	e8 4c ff ff ff       	call   c010159f <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101653:	8b 15 a0 80 11 c0    	mov    0xc01180a0,%edx
c0101659:	a1 a4 80 11 c0       	mov    0xc01180a4,%eax
c010165e:	39 c2                	cmp    %eax,%edx
c0101660:	74 31                	je     c0101693 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101662:	a1 a0 80 11 c0       	mov    0xc01180a0,%eax
c0101667:	8d 50 01             	lea    0x1(%eax),%edx
c010166a:	89 15 a0 80 11 c0    	mov    %edx,0xc01180a0
c0101670:	0f b6 80 a0 7e 11 c0 	movzbl -0x3fee8160(%eax),%eax
c0101677:	0f b6 c0             	movzbl %al,%eax
c010167a:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c010167d:	a1 a0 80 11 c0       	mov    0xc01180a0,%eax
c0101682:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101687:	75 0a                	jne    c0101693 <cons_getc+0x5f>
                cons.rpos = 0;
c0101689:	c7 05 a0 80 11 c0 00 	movl   $0x0,0xc01180a0
c0101690:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0101693:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101696:	89 04 24             	mov    %eax,(%esp)
c0101699:	e8 71 f7 ff ff       	call   c0100e0f <__intr_restore>
    return c;
c010169e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016a1:	c9                   	leave  
c01016a2:	c3                   	ret    

c01016a3 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01016a3:	55                   	push   %ebp
c01016a4:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c01016a6:	fb                   	sti    
    sti();
}
c01016a7:	5d                   	pop    %ebp
c01016a8:	c3                   	ret    

c01016a9 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01016a9:	55                   	push   %ebp
c01016aa:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c01016ac:	fa                   	cli    
    cli();
}
c01016ad:	5d                   	pop    %ebp
c01016ae:	c3                   	ret    

c01016af <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016af:	55                   	push   %ebp
c01016b0:	89 e5                	mov    %esp,%ebp
c01016b2:	83 ec 14             	sub    $0x14,%esp
c01016b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01016b8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016bc:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016c0:	66 a3 70 75 11 c0    	mov    %ax,0xc0117570
    if (did_init) {
c01016c6:	a1 ac 80 11 c0       	mov    0xc01180ac,%eax
c01016cb:	85 c0                	test   %eax,%eax
c01016cd:	74 36                	je     c0101705 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c01016cf:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016d3:	0f b6 c0             	movzbl %al,%eax
c01016d6:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01016dc:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016df:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01016e3:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01016e7:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c01016e8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016ec:	66 c1 e8 08          	shr    $0x8,%ax
c01016f0:	0f b6 c0             	movzbl %al,%eax
c01016f3:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c01016f9:	88 45 f9             	mov    %al,-0x7(%ebp)
c01016fc:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101700:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101704:	ee                   	out    %al,(%dx)
    }
}
c0101705:	c9                   	leave  
c0101706:	c3                   	ret    

c0101707 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101707:	55                   	push   %ebp
c0101708:	89 e5                	mov    %esp,%ebp
c010170a:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c010170d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101710:	ba 01 00 00 00       	mov    $0x1,%edx
c0101715:	89 c1                	mov    %eax,%ecx
c0101717:	d3 e2                	shl    %cl,%edx
c0101719:	89 d0                	mov    %edx,%eax
c010171b:	f7 d0                	not    %eax
c010171d:	89 c2                	mov    %eax,%edx
c010171f:	0f b7 05 70 75 11 c0 	movzwl 0xc0117570,%eax
c0101726:	21 d0                	and    %edx,%eax
c0101728:	0f b7 c0             	movzwl %ax,%eax
c010172b:	89 04 24             	mov    %eax,(%esp)
c010172e:	e8 7c ff ff ff       	call   c01016af <pic_setmask>
}
c0101733:	c9                   	leave  
c0101734:	c3                   	ret    

c0101735 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101735:	55                   	push   %ebp
c0101736:	89 e5                	mov    %esp,%ebp
c0101738:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c010173b:	c7 05 ac 80 11 c0 01 	movl   $0x1,0xc01180ac
c0101742:	00 00 00 
c0101745:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c010174b:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c010174f:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101753:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101757:	ee                   	out    %al,(%dx)
c0101758:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c010175e:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c0101762:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101766:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010176a:	ee                   	out    %al,(%dx)
c010176b:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0101771:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0101775:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101779:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010177d:	ee                   	out    %al,(%dx)
c010177e:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c0101784:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c0101788:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010178c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101790:	ee                   	out    %al,(%dx)
c0101791:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c0101797:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c010179b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010179f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01017a3:	ee                   	out    %al,(%dx)
c01017a4:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c01017aa:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c01017ae:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01017b2:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01017b6:	ee                   	out    %al,(%dx)
c01017b7:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01017bd:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c01017c1:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01017c5:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01017c9:	ee                   	out    %al,(%dx)
c01017ca:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c01017d0:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c01017d4:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01017d8:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01017dc:	ee                   	out    %al,(%dx)
c01017dd:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c01017e3:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c01017e7:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01017eb:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01017ef:	ee                   	out    %al,(%dx)
c01017f0:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c01017f6:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c01017fa:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01017fe:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101802:	ee                   	out    %al,(%dx)
c0101803:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c0101809:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c010180d:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101811:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101815:	ee                   	out    %al,(%dx)
c0101816:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c010181c:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c0101820:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101824:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101828:	ee                   	out    %al,(%dx)
c0101829:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c010182f:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c0101833:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101837:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c010183b:	ee                   	out    %al,(%dx)
c010183c:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c0101842:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c0101846:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010184a:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c010184e:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010184f:	0f b7 05 70 75 11 c0 	movzwl 0xc0117570,%eax
c0101856:	66 83 f8 ff          	cmp    $0xffff,%ax
c010185a:	74 12                	je     c010186e <pic_init+0x139>
        pic_setmask(irq_mask);
c010185c:	0f b7 05 70 75 11 c0 	movzwl 0xc0117570,%eax
c0101863:	0f b7 c0             	movzwl %ax,%eax
c0101866:	89 04 24             	mov    %eax,(%esp)
c0101869:	e8 41 fe ff ff       	call   c01016af <pic_setmask>
    }
}
c010186e:	c9                   	leave  
c010186f:	c3                   	ret    

c0101870 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0101870:	55                   	push   %ebp
c0101871:	89 e5                	mov    %esp,%ebp
c0101873:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0101876:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c010187d:	00 
c010187e:	c7 04 24 20 62 10 c0 	movl   $0xc0106220,(%esp)
c0101885:	e8 b2 ea ff ff       	call   c010033c <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c010188a:	c9                   	leave  
c010188b:	c3                   	ret    

c010188c <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c010188c:	55                   	push   %ebp
c010188d:	89 e5                	mov    %esp,%ebp
c010188f:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0101892:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101899:	e9 c3 00 00 00       	jmp    c0101961 <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c010189e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018a1:	8b 04 85 00 76 11 c0 	mov    -0x3fee8a00(,%eax,4),%eax
c01018a8:	89 c2                	mov    %eax,%edx
c01018aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018ad:	66 89 14 c5 c0 80 11 	mov    %dx,-0x3fee7f40(,%eax,8)
c01018b4:	c0 
c01018b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018b8:	66 c7 04 c5 c2 80 11 	movw   $0x8,-0x3fee7f3e(,%eax,8)
c01018bf:	c0 08 00 
c01018c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018c5:	0f b6 14 c5 c4 80 11 	movzbl -0x3fee7f3c(,%eax,8),%edx
c01018cc:	c0 
c01018cd:	83 e2 e0             	and    $0xffffffe0,%edx
c01018d0:	88 14 c5 c4 80 11 c0 	mov    %dl,-0x3fee7f3c(,%eax,8)
c01018d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018da:	0f b6 14 c5 c4 80 11 	movzbl -0x3fee7f3c(,%eax,8),%edx
c01018e1:	c0 
c01018e2:	83 e2 1f             	and    $0x1f,%edx
c01018e5:	88 14 c5 c4 80 11 c0 	mov    %dl,-0x3fee7f3c(,%eax,8)
c01018ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018ef:	0f b6 14 c5 c5 80 11 	movzbl -0x3fee7f3b(,%eax,8),%edx
c01018f6:	c0 
c01018f7:	83 e2 f0             	and    $0xfffffff0,%edx
c01018fa:	83 ca 0e             	or     $0xe,%edx
c01018fd:	88 14 c5 c5 80 11 c0 	mov    %dl,-0x3fee7f3b(,%eax,8)
c0101904:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101907:	0f b6 14 c5 c5 80 11 	movzbl -0x3fee7f3b(,%eax,8),%edx
c010190e:	c0 
c010190f:	83 e2 ef             	and    $0xffffffef,%edx
c0101912:	88 14 c5 c5 80 11 c0 	mov    %dl,-0x3fee7f3b(,%eax,8)
c0101919:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010191c:	0f b6 14 c5 c5 80 11 	movzbl -0x3fee7f3b(,%eax,8),%edx
c0101923:	c0 
c0101924:	83 e2 9f             	and    $0xffffff9f,%edx
c0101927:	88 14 c5 c5 80 11 c0 	mov    %dl,-0x3fee7f3b(,%eax,8)
c010192e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101931:	0f b6 14 c5 c5 80 11 	movzbl -0x3fee7f3b(,%eax,8),%edx
c0101938:	c0 
c0101939:	83 ca 80             	or     $0xffffff80,%edx
c010193c:	88 14 c5 c5 80 11 c0 	mov    %dl,-0x3fee7f3b(,%eax,8)
c0101943:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101946:	8b 04 85 00 76 11 c0 	mov    -0x3fee8a00(,%eax,4),%eax
c010194d:	c1 e8 10             	shr    $0x10,%eax
c0101950:	89 c2                	mov    %eax,%edx
c0101952:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101955:	66 89 14 c5 c6 80 11 	mov    %dx,-0x3fee7f3a(,%eax,8)
c010195c:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c010195d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101961:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101964:	3d ff 00 00 00       	cmp    $0xff,%eax
c0101969:	0f 86 2f ff ff ff    	jbe    c010189e <idt_init+0x12>
c010196f:	c7 45 f8 80 75 11 c0 	movl   $0xc0117580,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101976:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101979:	0f 01 18             	lidtl  (%eax)
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    lidt(&idt_pd);
}
c010197c:	c9                   	leave  
c010197d:	c3                   	ret    

c010197e <trapname>:

static const char *
trapname(int trapno) {
c010197e:	55                   	push   %ebp
c010197f:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101981:	8b 45 08             	mov    0x8(%ebp),%eax
c0101984:	83 f8 13             	cmp    $0x13,%eax
c0101987:	77 0c                	ja     c0101995 <trapname+0x17>
        return excnames[trapno];
c0101989:	8b 45 08             	mov    0x8(%ebp),%eax
c010198c:	8b 04 85 80 65 10 c0 	mov    -0x3fef9a80(,%eax,4),%eax
c0101993:	eb 18                	jmp    c01019ad <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101995:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101999:	7e 0d                	jle    c01019a8 <trapname+0x2a>
c010199b:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c010199f:	7f 07                	jg     c01019a8 <trapname+0x2a>
        return "Hardware Interrupt";
c01019a1:	b8 2a 62 10 c0       	mov    $0xc010622a,%eax
c01019a6:	eb 05                	jmp    c01019ad <trapname+0x2f>
    }
    return "(unknown trap)";
c01019a8:	b8 3d 62 10 c0       	mov    $0xc010623d,%eax
}
c01019ad:	5d                   	pop    %ebp
c01019ae:	c3                   	ret    

c01019af <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01019af:	55                   	push   %ebp
c01019b0:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01019b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01019b5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01019b9:	66 83 f8 08          	cmp    $0x8,%ax
c01019bd:	0f 94 c0             	sete   %al
c01019c0:	0f b6 c0             	movzbl %al,%eax
}
c01019c3:	5d                   	pop    %ebp
c01019c4:	c3                   	ret    

c01019c5 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01019c5:	55                   	push   %ebp
c01019c6:	89 e5                	mov    %esp,%ebp
c01019c8:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01019cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01019ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01019d2:	c7 04 24 7e 62 10 c0 	movl   $0xc010627e,(%esp)
c01019d9:	e8 5e e9 ff ff       	call   c010033c <cprintf>
    print_regs(&tf->tf_regs);
c01019de:	8b 45 08             	mov    0x8(%ebp),%eax
c01019e1:	89 04 24             	mov    %eax,(%esp)
c01019e4:	e8 a1 01 00 00       	call   c0101b8a <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c01019e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01019ec:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c01019f0:	0f b7 c0             	movzwl %ax,%eax
c01019f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01019f7:	c7 04 24 8f 62 10 c0 	movl   $0xc010628f,(%esp)
c01019fe:	e8 39 e9 ff ff       	call   c010033c <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101a03:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a06:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101a0a:	0f b7 c0             	movzwl %ax,%eax
c0101a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a11:	c7 04 24 a2 62 10 c0 	movl   $0xc01062a2,(%esp)
c0101a18:	e8 1f e9 ff ff       	call   c010033c <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101a1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a20:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101a24:	0f b7 c0             	movzwl %ax,%eax
c0101a27:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a2b:	c7 04 24 b5 62 10 c0 	movl   $0xc01062b5,(%esp)
c0101a32:	e8 05 e9 ff ff       	call   c010033c <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101a37:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a3a:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101a3e:	0f b7 c0             	movzwl %ax,%eax
c0101a41:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a45:	c7 04 24 c8 62 10 c0 	movl   $0xc01062c8,(%esp)
c0101a4c:	e8 eb e8 ff ff       	call   c010033c <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101a51:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a54:	8b 40 30             	mov    0x30(%eax),%eax
c0101a57:	89 04 24             	mov    %eax,(%esp)
c0101a5a:	e8 1f ff ff ff       	call   c010197e <trapname>
c0101a5f:	8b 55 08             	mov    0x8(%ebp),%edx
c0101a62:	8b 52 30             	mov    0x30(%edx),%edx
c0101a65:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101a69:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101a6d:	c7 04 24 db 62 10 c0 	movl   $0xc01062db,(%esp)
c0101a74:	e8 c3 e8 ff ff       	call   c010033c <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101a79:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a7c:	8b 40 34             	mov    0x34(%eax),%eax
c0101a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a83:	c7 04 24 ed 62 10 c0 	movl   $0xc01062ed,(%esp)
c0101a8a:	e8 ad e8 ff ff       	call   c010033c <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101a8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a92:	8b 40 38             	mov    0x38(%eax),%eax
c0101a95:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a99:	c7 04 24 fc 62 10 c0 	movl   $0xc01062fc,(%esp)
c0101aa0:	e8 97 e8 ff ff       	call   c010033c <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101aa5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101aac:	0f b7 c0             	movzwl %ax,%eax
c0101aaf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ab3:	c7 04 24 0b 63 10 c0 	movl   $0xc010630b,(%esp)
c0101aba:	e8 7d e8 ff ff       	call   c010033c <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101abf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ac2:	8b 40 40             	mov    0x40(%eax),%eax
c0101ac5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ac9:	c7 04 24 1e 63 10 c0 	movl   $0xc010631e,(%esp)
c0101ad0:	e8 67 e8 ff ff       	call   c010033c <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101ad5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101adc:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101ae3:	eb 3e                	jmp    c0101b23 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101ae5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ae8:	8b 50 40             	mov    0x40(%eax),%edx
c0101aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101aee:	21 d0                	and    %edx,%eax
c0101af0:	85 c0                	test   %eax,%eax
c0101af2:	74 28                	je     c0101b1c <print_trapframe+0x157>
c0101af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101af7:	8b 04 85 a0 75 11 c0 	mov    -0x3fee8a60(,%eax,4),%eax
c0101afe:	85 c0                	test   %eax,%eax
c0101b00:	74 1a                	je     c0101b1c <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0101b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b05:	8b 04 85 a0 75 11 c0 	mov    -0x3fee8a60(,%eax,4),%eax
c0101b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b10:	c7 04 24 2d 63 10 c0 	movl   $0xc010632d,(%esp)
c0101b17:	e8 20 e8 ff ff       	call   c010033c <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b1c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101b20:	d1 65 f0             	shll   -0x10(%ebp)
c0101b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b26:	83 f8 17             	cmp    $0x17,%eax
c0101b29:	76 ba                	jbe    c0101ae5 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101b2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b2e:	8b 40 40             	mov    0x40(%eax),%eax
c0101b31:	25 00 30 00 00       	and    $0x3000,%eax
c0101b36:	c1 e8 0c             	shr    $0xc,%eax
c0101b39:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b3d:	c7 04 24 31 63 10 c0 	movl   $0xc0106331,(%esp)
c0101b44:	e8 f3 e7 ff ff       	call   c010033c <cprintf>

    if (!trap_in_kernel(tf)) {
c0101b49:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b4c:	89 04 24             	mov    %eax,(%esp)
c0101b4f:	e8 5b fe ff ff       	call   c01019af <trap_in_kernel>
c0101b54:	85 c0                	test   %eax,%eax
c0101b56:	75 30                	jne    c0101b88 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101b58:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b5b:	8b 40 44             	mov    0x44(%eax),%eax
c0101b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b62:	c7 04 24 3a 63 10 c0 	movl   $0xc010633a,(%esp)
c0101b69:	e8 ce e7 ff ff       	call   c010033c <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b71:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101b75:	0f b7 c0             	movzwl %ax,%eax
c0101b78:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b7c:	c7 04 24 49 63 10 c0 	movl   $0xc0106349,(%esp)
c0101b83:	e8 b4 e7 ff ff       	call   c010033c <cprintf>
    }
}
c0101b88:	c9                   	leave  
c0101b89:	c3                   	ret    

c0101b8a <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101b8a:	55                   	push   %ebp
c0101b8b:	89 e5                	mov    %esp,%ebp
c0101b8d:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101b90:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b93:	8b 00                	mov    (%eax),%eax
c0101b95:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b99:	c7 04 24 5c 63 10 c0 	movl   $0xc010635c,(%esp)
c0101ba0:	e8 97 e7 ff ff       	call   c010033c <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101ba5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ba8:	8b 40 04             	mov    0x4(%eax),%eax
c0101bab:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101baf:	c7 04 24 6b 63 10 c0 	movl   $0xc010636b,(%esp)
c0101bb6:	e8 81 e7 ff ff       	call   c010033c <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101bbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bbe:	8b 40 08             	mov    0x8(%eax),%eax
c0101bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bc5:	c7 04 24 7a 63 10 c0 	movl   $0xc010637a,(%esp)
c0101bcc:	e8 6b e7 ff ff       	call   c010033c <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101bd1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bd4:	8b 40 0c             	mov    0xc(%eax),%eax
c0101bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bdb:	c7 04 24 89 63 10 c0 	movl   $0xc0106389,(%esp)
c0101be2:	e8 55 e7 ff ff       	call   c010033c <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101be7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bea:	8b 40 10             	mov    0x10(%eax),%eax
c0101bed:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bf1:	c7 04 24 98 63 10 c0 	movl   $0xc0106398,(%esp)
c0101bf8:	e8 3f e7 ff ff       	call   c010033c <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101bfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c00:	8b 40 14             	mov    0x14(%eax),%eax
c0101c03:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c07:	c7 04 24 a7 63 10 c0 	movl   $0xc01063a7,(%esp)
c0101c0e:	e8 29 e7 ff ff       	call   c010033c <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101c13:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c16:	8b 40 18             	mov    0x18(%eax),%eax
c0101c19:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c1d:	c7 04 24 b6 63 10 c0 	movl   $0xc01063b6,(%esp)
c0101c24:	e8 13 e7 ff ff       	call   c010033c <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101c29:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c2c:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101c2f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c33:	c7 04 24 c5 63 10 c0 	movl   $0xc01063c5,(%esp)
c0101c3a:	e8 fd e6 ff ff       	call   c010033c <cprintf>
}
c0101c3f:	c9                   	leave  
c0101c40:	c3                   	ret    

c0101c41 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101c41:	55                   	push   %ebp
c0101c42:	89 e5                	mov    %esp,%ebp
c0101c44:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101c47:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c4a:	8b 40 30             	mov    0x30(%eax),%eax
c0101c4d:	83 f8 2f             	cmp    $0x2f,%eax
c0101c50:	77 21                	ja     c0101c73 <trap_dispatch+0x32>
c0101c52:	83 f8 2e             	cmp    $0x2e,%eax
c0101c55:	0f 83 04 01 00 00    	jae    c0101d5f <trap_dispatch+0x11e>
c0101c5b:	83 f8 21             	cmp    $0x21,%eax
c0101c5e:	0f 84 81 00 00 00    	je     c0101ce5 <trap_dispatch+0xa4>
c0101c64:	83 f8 24             	cmp    $0x24,%eax
c0101c67:	74 56                	je     c0101cbf <trap_dispatch+0x7e>
c0101c69:	83 f8 20             	cmp    $0x20,%eax
c0101c6c:	74 16                	je     c0101c84 <trap_dispatch+0x43>
c0101c6e:	e9 b4 00 00 00       	jmp    c0101d27 <trap_dispatch+0xe6>
c0101c73:	83 e8 78             	sub    $0x78,%eax
c0101c76:	83 f8 01             	cmp    $0x1,%eax
c0101c79:	0f 87 a8 00 00 00    	ja     c0101d27 <trap_dispatch+0xe6>
c0101c7f:	e9 87 00 00 00       	jmp    c0101d0b <trap_dispatch+0xca>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0101c84:	a1 4c 89 11 c0       	mov    0xc011894c,%eax
c0101c89:	83 c0 01             	add    $0x1,%eax
c0101c8c:	a3 4c 89 11 c0       	mov    %eax,0xc011894c
        if (ticks % TICK_NUM == 0) {
c0101c91:	8b 0d 4c 89 11 c0    	mov    0xc011894c,%ecx
c0101c97:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101c9c:	89 c8                	mov    %ecx,%eax
c0101c9e:	f7 e2                	mul    %edx
c0101ca0:	89 d0                	mov    %edx,%eax
c0101ca2:	c1 e8 05             	shr    $0x5,%eax
c0101ca5:	6b c0 64             	imul   $0x64,%eax,%eax
c0101ca8:	29 c1                	sub    %eax,%ecx
c0101caa:	89 c8                	mov    %ecx,%eax
c0101cac:	85 c0                	test   %eax,%eax
c0101cae:	75 0a                	jne    c0101cba <trap_dispatch+0x79>
            print_ticks();
c0101cb0:	e8 bb fb ff ff       	call   c0101870 <print_ticks>
        }
        break;
c0101cb5:	e9 a6 00 00 00       	jmp    c0101d60 <trap_dispatch+0x11f>
c0101cba:	e9 a1 00 00 00       	jmp    c0101d60 <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101cbf:	e8 70 f9 ff ff       	call   c0101634 <cons_getc>
c0101cc4:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101cc7:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101ccb:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101ccf:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101cd3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cd7:	c7 04 24 d4 63 10 c0 	movl   $0xc01063d4,(%esp)
c0101cde:	e8 59 e6 ff ff       	call   c010033c <cprintf>
        break;
c0101ce3:	eb 7b                	jmp    c0101d60 <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101ce5:	e8 4a f9 ff ff       	call   c0101634 <cons_getc>
c0101cea:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101ced:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101cf1:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101cf5:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cfd:	c7 04 24 e6 63 10 c0 	movl   $0xc01063e6,(%esp)
c0101d04:	e8 33 e6 ff ff       	call   c010033c <cprintf>
        break;
c0101d09:	eb 55                	jmp    c0101d60 <trap_dispatch+0x11f>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101d0b:	c7 44 24 08 f5 63 10 	movl   $0xc01063f5,0x8(%esp)
c0101d12:	c0 
c0101d13:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
c0101d1a:	00 
c0101d1b:	c7 04 24 05 64 10 c0 	movl   $0xc0106405,(%esp)
c0101d22:	e8 9f ef ff ff       	call   c0100cc6 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101d27:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d2a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101d2e:	0f b7 c0             	movzwl %ax,%eax
c0101d31:	83 e0 03             	and    $0x3,%eax
c0101d34:	85 c0                	test   %eax,%eax
c0101d36:	75 28                	jne    c0101d60 <trap_dispatch+0x11f>
            print_trapframe(tf);
c0101d38:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d3b:	89 04 24             	mov    %eax,(%esp)
c0101d3e:	e8 82 fc ff ff       	call   c01019c5 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101d43:	c7 44 24 08 16 64 10 	movl   $0xc0106416,0x8(%esp)
c0101d4a:	c0 
c0101d4b:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c0101d52:	00 
c0101d53:	c7 04 24 05 64 10 c0 	movl   $0xc0106405,(%esp)
c0101d5a:	e8 67 ef ff ff       	call   c0100cc6 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0101d5f:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0101d60:	c9                   	leave  
c0101d61:	c3                   	ret    

c0101d62 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101d62:	55                   	push   %ebp
c0101d63:	89 e5                	mov    %esp,%ebp
c0101d65:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101d68:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d6b:	89 04 24             	mov    %eax,(%esp)
c0101d6e:	e8 ce fe ff ff       	call   c0101c41 <trap_dispatch>
}
c0101d73:	c9                   	leave  
c0101d74:	c3                   	ret    

c0101d75 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0101d75:	1e                   	push   %ds
    pushl %es
c0101d76:	06                   	push   %es
    pushl %fs
c0101d77:	0f a0                	push   %fs
    pushl %gs
c0101d79:	0f a8                	push   %gs
    pushal
c0101d7b:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0101d7c:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0101d81:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0101d83:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0101d85:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0101d86:	e8 d7 ff ff ff       	call   c0101d62 <trap>

    # pop the pushed stack pointer
    popl %esp
c0101d8b:	5c                   	pop    %esp

c0101d8c <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0101d8c:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0101d8d:	0f a9                	pop    %gs
    popl %fs
c0101d8f:	0f a1                	pop    %fs
    popl %es
c0101d91:	07                   	pop    %es
    popl %ds
c0101d92:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0101d93:	83 c4 08             	add    $0x8,%esp
    iret
c0101d96:	cf                   	iret   

c0101d97 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101d97:	6a 00                	push   $0x0
  pushl $0
c0101d99:	6a 00                	push   $0x0
  jmp __alltraps
c0101d9b:	e9 d5 ff ff ff       	jmp    c0101d75 <__alltraps>

c0101da0 <vector1>:
.globl vector1
vector1:
  pushl $0
c0101da0:	6a 00                	push   $0x0
  pushl $1
c0101da2:	6a 01                	push   $0x1
  jmp __alltraps
c0101da4:	e9 cc ff ff ff       	jmp    c0101d75 <__alltraps>

c0101da9 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101da9:	6a 00                	push   $0x0
  pushl $2
c0101dab:	6a 02                	push   $0x2
  jmp __alltraps
c0101dad:	e9 c3 ff ff ff       	jmp    c0101d75 <__alltraps>

c0101db2 <vector3>:
.globl vector3
vector3:
  pushl $0
c0101db2:	6a 00                	push   $0x0
  pushl $3
c0101db4:	6a 03                	push   $0x3
  jmp __alltraps
c0101db6:	e9 ba ff ff ff       	jmp    c0101d75 <__alltraps>

c0101dbb <vector4>:
.globl vector4
vector4:
  pushl $0
c0101dbb:	6a 00                	push   $0x0
  pushl $4
c0101dbd:	6a 04                	push   $0x4
  jmp __alltraps
c0101dbf:	e9 b1 ff ff ff       	jmp    c0101d75 <__alltraps>

c0101dc4 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101dc4:	6a 00                	push   $0x0
  pushl $5
c0101dc6:	6a 05                	push   $0x5
  jmp __alltraps
c0101dc8:	e9 a8 ff ff ff       	jmp    c0101d75 <__alltraps>

c0101dcd <vector6>:
.globl vector6
vector6:
  pushl $0
c0101dcd:	6a 00                	push   $0x0
  pushl $6
c0101dcf:	6a 06                	push   $0x6
  jmp __alltraps
c0101dd1:	e9 9f ff ff ff       	jmp    c0101d75 <__alltraps>

c0101dd6 <vector7>:
.globl vector7
vector7:
  pushl $0
c0101dd6:	6a 00                	push   $0x0
  pushl $7
c0101dd8:	6a 07                	push   $0x7
  jmp __alltraps
c0101dda:	e9 96 ff ff ff       	jmp    c0101d75 <__alltraps>

c0101ddf <vector8>:
.globl vector8
vector8:
  pushl $8
c0101ddf:	6a 08                	push   $0x8
  jmp __alltraps
c0101de1:	e9 8f ff ff ff       	jmp    c0101d75 <__alltraps>

c0101de6 <vector9>:
.globl vector9
vector9:
  pushl $9
c0101de6:	6a 09                	push   $0x9
  jmp __alltraps
c0101de8:	e9 88 ff ff ff       	jmp    c0101d75 <__alltraps>

c0101ded <vector10>:
.globl vector10
vector10:
  pushl $10
c0101ded:	6a 0a                	push   $0xa
  jmp __alltraps
c0101def:	e9 81 ff ff ff       	jmp    c0101d75 <__alltraps>

c0101df4 <vector11>:
.globl vector11
vector11:
  pushl $11
c0101df4:	6a 0b                	push   $0xb
  jmp __alltraps
c0101df6:	e9 7a ff ff ff       	jmp    c0101d75 <__alltraps>

c0101dfb <vector12>:
.globl vector12
vector12:
  pushl $12
c0101dfb:	6a 0c                	push   $0xc
  jmp __alltraps
c0101dfd:	e9 73 ff ff ff       	jmp    c0101d75 <__alltraps>

c0101e02 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101e02:	6a 0d                	push   $0xd
  jmp __alltraps
c0101e04:	e9 6c ff ff ff       	jmp    c0101d75 <__alltraps>

c0101e09 <vector14>:
.globl vector14
vector14:
  pushl $14
c0101e09:	6a 0e                	push   $0xe
  jmp __alltraps
c0101e0b:	e9 65 ff ff ff       	jmp    c0101d75 <__alltraps>

c0101e10 <vector15>:
.globl vector15
vector15:
  pushl $0
c0101e10:	6a 00                	push   $0x0
  pushl $15
c0101e12:	6a 0f                	push   $0xf
  jmp __alltraps
c0101e14:	e9 5c ff ff ff       	jmp    c0101d75 <__alltraps>

c0101e19 <vector16>:
.globl vector16
vector16:
  pushl $0
c0101e19:	6a 00                	push   $0x0
  pushl $16
c0101e1b:	6a 10                	push   $0x10
  jmp __alltraps
c0101e1d:	e9 53 ff ff ff       	jmp    c0101d75 <__alltraps>

c0101e22 <vector17>:
.globl vector17
vector17:
  pushl $17
c0101e22:	6a 11                	push   $0x11
  jmp __alltraps
c0101e24:	e9 4c ff ff ff       	jmp    c0101d75 <__alltraps>

c0101e29 <vector18>:
.globl vector18
vector18:
  pushl $0
c0101e29:	6a 00                	push   $0x0
  pushl $18
c0101e2b:	6a 12                	push   $0x12
  jmp __alltraps
c0101e2d:	e9 43 ff ff ff       	jmp    c0101d75 <__alltraps>

c0101e32 <vector19>:
.globl vector19
vector19:
  pushl $0
c0101e32:	6a 00                	push   $0x0
  pushl $19
c0101e34:	6a 13                	push   $0x13
  jmp __alltraps
c0101e36:	e9 3a ff ff ff       	jmp    c0101d75 <__alltraps>

c0101e3b <vector20>:
.globl vector20
vector20:
  pushl $0
c0101e3b:	6a 00                	push   $0x0
  pushl $20
c0101e3d:	6a 14                	push   $0x14
  jmp __alltraps
c0101e3f:	e9 31 ff ff ff       	jmp    c0101d75 <__alltraps>

c0101e44 <vector21>:
.globl vector21
vector21:
  pushl $0
c0101e44:	6a 00                	push   $0x0
  pushl $21
c0101e46:	6a 15                	push   $0x15
  jmp __alltraps
c0101e48:	e9 28 ff ff ff       	jmp    c0101d75 <__alltraps>

c0101e4d <vector22>:
.globl vector22
vector22:
  pushl $0
c0101e4d:	6a 00                	push   $0x0
  pushl $22
c0101e4f:	6a 16                	push   $0x16
  jmp __alltraps
c0101e51:	e9 1f ff ff ff       	jmp    c0101d75 <__alltraps>

c0101e56 <vector23>:
.globl vector23
vector23:
  pushl $0
c0101e56:	6a 00                	push   $0x0
  pushl $23
c0101e58:	6a 17                	push   $0x17
  jmp __alltraps
c0101e5a:	e9 16 ff ff ff       	jmp    c0101d75 <__alltraps>

c0101e5f <vector24>:
.globl vector24
vector24:
  pushl $0
c0101e5f:	6a 00                	push   $0x0
  pushl $24
c0101e61:	6a 18                	push   $0x18
  jmp __alltraps
c0101e63:	e9 0d ff ff ff       	jmp    c0101d75 <__alltraps>

c0101e68 <vector25>:
.globl vector25
vector25:
  pushl $0
c0101e68:	6a 00                	push   $0x0
  pushl $25
c0101e6a:	6a 19                	push   $0x19
  jmp __alltraps
c0101e6c:	e9 04 ff ff ff       	jmp    c0101d75 <__alltraps>

c0101e71 <vector26>:
.globl vector26
vector26:
  pushl $0
c0101e71:	6a 00                	push   $0x0
  pushl $26
c0101e73:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101e75:	e9 fb fe ff ff       	jmp    c0101d75 <__alltraps>

c0101e7a <vector27>:
.globl vector27
vector27:
  pushl $0
c0101e7a:	6a 00                	push   $0x0
  pushl $27
c0101e7c:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101e7e:	e9 f2 fe ff ff       	jmp    c0101d75 <__alltraps>

c0101e83 <vector28>:
.globl vector28
vector28:
  pushl $0
c0101e83:	6a 00                	push   $0x0
  pushl $28
c0101e85:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101e87:	e9 e9 fe ff ff       	jmp    c0101d75 <__alltraps>

c0101e8c <vector29>:
.globl vector29
vector29:
  pushl $0
c0101e8c:	6a 00                	push   $0x0
  pushl $29
c0101e8e:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101e90:	e9 e0 fe ff ff       	jmp    c0101d75 <__alltraps>

c0101e95 <vector30>:
.globl vector30
vector30:
  pushl $0
c0101e95:	6a 00                	push   $0x0
  pushl $30
c0101e97:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101e99:	e9 d7 fe ff ff       	jmp    c0101d75 <__alltraps>

c0101e9e <vector31>:
.globl vector31
vector31:
  pushl $0
c0101e9e:	6a 00                	push   $0x0
  pushl $31
c0101ea0:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101ea2:	e9 ce fe ff ff       	jmp    c0101d75 <__alltraps>

c0101ea7 <vector32>:
.globl vector32
vector32:
  pushl $0
c0101ea7:	6a 00                	push   $0x0
  pushl $32
c0101ea9:	6a 20                	push   $0x20
  jmp __alltraps
c0101eab:	e9 c5 fe ff ff       	jmp    c0101d75 <__alltraps>

c0101eb0 <vector33>:
.globl vector33
vector33:
  pushl $0
c0101eb0:	6a 00                	push   $0x0
  pushl $33
c0101eb2:	6a 21                	push   $0x21
  jmp __alltraps
c0101eb4:	e9 bc fe ff ff       	jmp    c0101d75 <__alltraps>

c0101eb9 <vector34>:
.globl vector34
vector34:
  pushl $0
c0101eb9:	6a 00                	push   $0x0
  pushl $34
c0101ebb:	6a 22                	push   $0x22
  jmp __alltraps
c0101ebd:	e9 b3 fe ff ff       	jmp    c0101d75 <__alltraps>

c0101ec2 <vector35>:
.globl vector35
vector35:
  pushl $0
c0101ec2:	6a 00                	push   $0x0
  pushl $35
c0101ec4:	6a 23                	push   $0x23
  jmp __alltraps
c0101ec6:	e9 aa fe ff ff       	jmp    c0101d75 <__alltraps>

c0101ecb <vector36>:
.globl vector36
vector36:
  pushl $0
c0101ecb:	6a 00                	push   $0x0
  pushl $36
c0101ecd:	6a 24                	push   $0x24
  jmp __alltraps
c0101ecf:	e9 a1 fe ff ff       	jmp    c0101d75 <__alltraps>

c0101ed4 <vector37>:
.globl vector37
vector37:
  pushl $0
c0101ed4:	6a 00                	push   $0x0
  pushl $37
c0101ed6:	6a 25                	push   $0x25
  jmp __alltraps
c0101ed8:	e9 98 fe ff ff       	jmp    c0101d75 <__alltraps>

c0101edd <vector38>:
.globl vector38
vector38:
  pushl $0
c0101edd:	6a 00                	push   $0x0
  pushl $38
c0101edf:	6a 26                	push   $0x26
  jmp __alltraps
c0101ee1:	e9 8f fe ff ff       	jmp    c0101d75 <__alltraps>

c0101ee6 <vector39>:
.globl vector39
vector39:
  pushl $0
c0101ee6:	6a 00                	push   $0x0
  pushl $39
c0101ee8:	6a 27                	push   $0x27
  jmp __alltraps
c0101eea:	e9 86 fe ff ff       	jmp    c0101d75 <__alltraps>

c0101eef <vector40>:
.globl vector40
vector40:
  pushl $0
c0101eef:	6a 00                	push   $0x0
  pushl $40
c0101ef1:	6a 28                	push   $0x28
  jmp __alltraps
c0101ef3:	e9 7d fe ff ff       	jmp    c0101d75 <__alltraps>

c0101ef8 <vector41>:
.globl vector41
vector41:
  pushl $0
c0101ef8:	6a 00                	push   $0x0
  pushl $41
c0101efa:	6a 29                	push   $0x29
  jmp __alltraps
c0101efc:	e9 74 fe ff ff       	jmp    c0101d75 <__alltraps>

c0101f01 <vector42>:
.globl vector42
vector42:
  pushl $0
c0101f01:	6a 00                	push   $0x0
  pushl $42
c0101f03:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101f05:	e9 6b fe ff ff       	jmp    c0101d75 <__alltraps>

c0101f0a <vector43>:
.globl vector43
vector43:
  pushl $0
c0101f0a:	6a 00                	push   $0x0
  pushl $43
c0101f0c:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101f0e:	e9 62 fe ff ff       	jmp    c0101d75 <__alltraps>

c0101f13 <vector44>:
.globl vector44
vector44:
  pushl $0
c0101f13:	6a 00                	push   $0x0
  pushl $44
c0101f15:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101f17:	e9 59 fe ff ff       	jmp    c0101d75 <__alltraps>

c0101f1c <vector45>:
.globl vector45
vector45:
  pushl $0
c0101f1c:	6a 00                	push   $0x0
  pushl $45
c0101f1e:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101f20:	e9 50 fe ff ff       	jmp    c0101d75 <__alltraps>

c0101f25 <vector46>:
.globl vector46
vector46:
  pushl $0
c0101f25:	6a 00                	push   $0x0
  pushl $46
c0101f27:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101f29:	e9 47 fe ff ff       	jmp    c0101d75 <__alltraps>

c0101f2e <vector47>:
.globl vector47
vector47:
  pushl $0
c0101f2e:	6a 00                	push   $0x0
  pushl $47
c0101f30:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101f32:	e9 3e fe ff ff       	jmp    c0101d75 <__alltraps>

c0101f37 <vector48>:
.globl vector48
vector48:
  pushl $0
c0101f37:	6a 00                	push   $0x0
  pushl $48
c0101f39:	6a 30                	push   $0x30
  jmp __alltraps
c0101f3b:	e9 35 fe ff ff       	jmp    c0101d75 <__alltraps>

c0101f40 <vector49>:
.globl vector49
vector49:
  pushl $0
c0101f40:	6a 00                	push   $0x0
  pushl $49
c0101f42:	6a 31                	push   $0x31
  jmp __alltraps
c0101f44:	e9 2c fe ff ff       	jmp    c0101d75 <__alltraps>

c0101f49 <vector50>:
.globl vector50
vector50:
  pushl $0
c0101f49:	6a 00                	push   $0x0
  pushl $50
c0101f4b:	6a 32                	push   $0x32
  jmp __alltraps
c0101f4d:	e9 23 fe ff ff       	jmp    c0101d75 <__alltraps>

c0101f52 <vector51>:
.globl vector51
vector51:
  pushl $0
c0101f52:	6a 00                	push   $0x0
  pushl $51
c0101f54:	6a 33                	push   $0x33
  jmp __alltraps
c0101f56:	e9 1a fe ff ff       	jmp    c0101d75 <__alltraps>

c0101f5b <vector52>:
.globl vector52
vector52:
  pushl $0
c0101f5b:	6a 00                	push   $0x0
  pushl $52
c0101f5d:	6a 34                	push   $0x34
  jmp __alltraps
c0101f5f:	e9 11 fe ff ff       	jmp    c0101d75 <__alltraps>

c0101f64 <vector53>:
.globl vector53
vector53:
  pushl $0
c0101f64:	6a 00                	push   $0x0
  pushl $53
c0101f66:	6a 35                	push   $0x35
  jmp __alltraps
c0101f68:	e9 08 fe ff ff       	jmp    c0101d75 <__alltraps>

c0101f6d <vector54>:
.globl vector54
vector54:
  pushl $0
c0101f6d:	6a 00                	push   $0x0
  pushl $54
c0101f6f:	6a 36                	push   $0x36
  jmp __alltraps
c0101f71:	e9 ff fd ff ff       	jmp    c0101d75 <__alltraps>

c0101f76 <vector55>:
.globl vector55
vector55:
  pushl $0
c0101f76:	6a 00                	push   $0x0
  pushl $55
c0101f78:	6a 37                	push   $0x37
  jmp __alltraps
c0101f7a:	e9 f6 fd ff ff       	jmp    c0101d75 <__alltraps>

c0101f7f <vector56>:
.globl vector56
vector56:
  pushl $0
c0101f7f:	6a 00                	push   $0x0
  pushl $56
c0101f81:	6a 38                	push   $0x38
  jmp __alltraps
c0101f83:	e9 ed fd ff ff       	jmp    c0101d75 <__alltraps>

c0101f88 <vector57>:
.globl vector57
vector57:
  pushl $0
c0101f88:	6a 00                	push   $0x0
  pushl $57
c0101f8a:	6a 39                	push   $0x39
  jmp __alltraps
c0101f8c:	e9 e4 fd ff ff       	jmp    c0101d75 <__alltraps>

c0101f91 <vector58>:
.globl vector58
vector58:
  pushl $0
c0101f91:	6a 00                	push   $0x0
  pushl $58
c0101f93:	6a 3a                	push   $0x3a
  jmp __alltraps
c0101f95:	e9 db fd ff ff       	jmp    c0101d75 <__alltraps>

c0101f9a <vector59>:
.globl vector59
vector59:
  pushl $0
c0101f9a:	6a 00                	push   $0x0
  pushl $59
c0101f9c:	6a 3b                	push   $0x3b
  jmp __alltraps
c0101f9e:	e9 d2 fd ff ff       	jmp    c0101d75 <__alltraps>

c0101fa3 <vector60>:
.globl vector60
vector60:
  pushl $0
c0101fa3:	6a 00                	push   $0x0
  pushl $60
c0101fa5:	6a 3c                	push   $0x3c
  jmp __alltraps
c0101fa7:	e9 c9 fd ff ff       	jmp    c0101d75 <__alltraps>

c0101fac <vector61>:
.globl vector61
vector61:
  pushl $0
c0101fac:	6a 00                	push   $0x0
  pushl $61
c0101fae:	6a 3d                	push   $0x3d
  jmp __alltraps
c0101fb0:	e9 c0 fd ff ff       	jmp    c0101d75 <__alltraps>

c0101fb5 <vector62>:
.globl vector62
vector62:
  pushl $0
c0101fb5:	6a 00                	push   $0x0
  pushl $62
c0101fb7:	6a 3e                	push   $0x3e
  jmp __alltraps
c0101fb9:	e9 b7 fd ff ff       	jmp    c0101d75 <__alltraps>

c0101fbe <vector63>:
.globl vector63
vector63:
  pushl $0
c0101fbe:	6a 00                	push   $0x0
  pushl $63
c0101fc0:	6a 3f                	push   $0x3f
  jmp __alltraps
c0101fc2:	e9 ae fd ff ff       	jmp    c0101d75 <__alltraps>

c0101fc7 <vector64>:
.globl vector64
vector64:
  pushl $0
c0101fc7:	6a 00                	push   $0x0
  pushl $64
c0101fc9:	6a 40                	push   $0x40
  jmp __alltraps
c0101fcb:	e9 a5 fd ff ff       	jmp    c0101d75 <__alltraps>

c0101fd0 <vector65>:
.globl vector65
vector65:
  pushl $0
c0101fd0:	6a 00                	push   $0x0
  pushl $65
c0101fd2:	6a 41                	push   $0x41
  jmp __alltraps
c0101fd4:	e9 9c fd ff ff       	jmp    c0101d75 <__alltraps>

c0101fd9 <vector66>:
.globl vector66
vector66:
  pushl $0
c0101fd9:	6a 00                	push   $0x0
  pushl $66
c0101fdb:	6a 42                	push   $0x42
  jmp __alltraps
c0101fdd:	e9 93 fd ff ff       	jmp    c0101d75 <__alltraps>

c0101fe2 <vector67>:
.globl vector67
vector67:
  pushl $0
c0101fe2:	6a 00                	push   $0x0
  pushl $67
c0101fe4:	6a 43                	push   $0x43
  jmp __alltraps
c0101fe6:	e9 8a fd ff ff       	jmp    c0101d75 <__alltraps>

c0101feb <vector68>:
.globl vector68
vector68:
  pushl $0
c0101feb:	6a 00                	push   $0x0
  pushl $68
c0101fed:	6a 44                	push   $0x44
  jmp __alltraps
c0101fef:	e9 81 fd ff ff       	jmp    c0101d75 <__alltraps>

c0101ff4 <vector69>:
.globl vector69
vector69:
  pushl $0
c0101ff4:	6a 00                	push   $0x0
  pushl $69
c0101ff6:	6a 45                	push   $0x45
  jmp __alltraps
c0101ff8:	e9 78 fd ff ff       	jmp    c0101d75 <__alltraps>

c0101ffd <vector70>:
.globl vector70
vector70:
  pushl $0
c0101ffd:	6a 00                	push   $0x0
  pushl $70
c0101fff:	6a 46                	push   $0x46
  jmp __alltraps
c0102001:	e9 6f fd ff ff       	jmp    c0101d75 <__alltraps>

c0102006 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102006:	6a 00                	push   $0x0
  pushl $71
c0102008:	6a 47                	push   $0x47
  jmp __alltraps
c010200a:	e9 66 fd ff ff       	jmp    c0101d75 <__alltraps>

c010200f <vector72>:
.globl vector72
vector72:
  pushl $0
c010200f:	6a 00                	push   $0x0
  pushl $72
c0102011:	6a 48                	push   $0x48
  jmp __alltraps
c0102013:	e9 5d fd ff ff       	jmp    c0101d75 <__alltraps>

c0102018 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102018:	6a 00                	push   $0x0
  pushl $73
c010201a:	6a 49                	push   $0x49
  jmp __alltraps
c010201c:	e9 54 fd ff ff       	jmp    c0101d75 <__alltraps>

c0102021 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102021:	6a 00                	push   $0x0
  pushl $74
c0102023:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102025:	e9 4b fd ff ff       	jmp    c0101d75 <__alltraps>

c010202a <vector75>:
.globl vector75
vector75:
  pushl $0
c010202a:	6a 00                	push   $0x0
  pushl $75
c010202c:	6a 4b                	push   $0x4b
  jmp __alltraps
c010202e:	e9 42 fd ff ff       	jmp    c0101d75 <__alltraps>

c0102033 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102033:	6a 00                	push   $0x0
  pushl $76
c0102035:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102037:	e9 39 fd ff ff       	jmp    c0101d75 <__alltraps>

c010203c <vector77>:
.globl vector77
vector77:
  pushl $0
c010203c:	6a 00                	push   $0x0
  pushl $77
c010203e:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102040:	e9 30 fd ff ff       	jmp    c0101d75 <__alltraps>

c0102045 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102045:	6a 00                	push   $0x0
  pushl $78
c0102047:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102049:	e9 27 fd ff ff       	jmp    c0101d75 <__alltraps>

c010204e <vector79>:
.globl vector79
vector79:
  pushl $0
c010204e:	6a 00                	push   $0x0
  pushl $79
c0102050:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102052:	e9 1e fd ff ff       	jmp    c0101d75 <__alltraps>

c0102057 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102057:	6a 00                	push   $0x0
  pushl $80
c0102059:	6a 50                	push   $0x50
  jmp __alltraps
c010205b:	e9 15 fd ff ff       	jmp    c0101d75 <__alltraps>

c0102060 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102060:	6a 00                	push   $0x0
  pushl $81
c0102062:	6a 51                	push   $0x51
  jmp __alltraps
c0102064:	e9 0c fd ff ff       	jmp    c0101d75 <__alltraps>

c0102069 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102069:	6a 00                	push   $0x0
  pushl $82
c010206b:	6a 52                	push   $0x52
  jmp __alltraps
c010206d:	e9 03 fd ff ff       	jmp    c0101d75 <__alltraps>

c0102072 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102072:	6a 00                	push   $0x0
  pushl $83
c0102074:	6a 53                	push   $0x53
  jmp __alltraps
c0102076:	e9 fa fc ff ff       	jmp    c0101d75 <__alltraps>

c010207b <vector84>:
.globl vector84
vector84:
  pushl $0
c010207b:	6a 00                	push   $0x0
  pushl $84
c010207d:	6a 54                	push   $0x54
  jmp __alltraps
c010207f:	e9 f1 fc ff ff       	jmp    c0101d75 <__alltraps>

c0102084 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102084:	6a 00                	push   $0x0
  pushl $85
c0102086:	6a 55                	push   $0x55
  jmp __alltraps
c0102088:	e9 e8 fc ff ff       	jmp    c0101d75 <__alltraps>

c010208d <vector86>:
.globl vector86
vector86:
  pushl $0
c010208d:	6a 00                	push   $0x0
  pushl $86
c010208f:	6a 56                	push   $0x56
  jmp __alltraps
c0102091:	e9 df fc ff ff       	jmp    c0101d75 <__alltraps>

c0102096 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102096:	6a 00                	push   $0x0
  pushl $87
c0102098:	6a 57                	push   $0x57
  jmp __alltraps
c010209a:	e9 d6 fc ff ff       	jmp    c0101d75 <__alltraps>

c010209f <vector88>:
.globl vector88
vector88:
  pushl $0
c010209f:	6a 00                	push   $0x0
  pushl $88
c01020a1:	6a 58                	push   $0x58
  jmp __alltraps
c01020a3:	e9 cd fc ff ff       	jmp    c0101d75 <__alltraps>

c01020a8 <vector89>:
.globl vector89
vector89:
  pushl $0
c01020a8:	6a 00                	push   $0x0
  pushl $89
c01020aa:	6a 59                	push   $0x59
  jmp __alltraps
c01020ac:	e9 c4 fc ff ff       	jmp    c0101d75 <__alltraps>

c01020b1 <vector90>:
.globl vector90
vector90:
  pushl $0
c01020b1:	6a 00                	push   $0x0
  pushl $90
c01020b3:	6a 5a                	push   $0x5a
  jmp __alltraps
c01020b5:	e9 bb fc ff ff       	jmp    c0101d75 <__alltraps>

c01020ba <vector91>:
.globl vector91
vector91:
  pushl $0
c01020ba:	6a 00                	push   $0x0
  pushl $91
c01020bc:	6a 5b                	push   $0x5b
  jmp __alltraps
c01020be:	e9 b2 fc ff ff       	jmp    c0101d75 <__alltraps>

c01020c3 <vector92>:
.globl vector92
vector92:
  pushl $0
c01020c3:	6a 00                	push   $0x0
  pushl $92
c01020c5:	6a 5c                	push   $0x5c
  jmp __alltraps
c01020c7:	e9 a9 fc ff ff       	jmp    c0101d75 <__alltraps>

c01020cc <vector93>:
.globl vector93
vector93:
  pushl $0
c01020cc:	6a 00                	push   $0x0
  pushl $93
c01020ce:	6a 5d                	push   $0x5d
  jmp __alltraps
c01020d0:	e9 a0 fc ff ff       	jmp    c0101d75 <__alltraps>

c01020d5 <vector94>:
.globl vector94
vector94:
  pushl $0
c01020d5:	6a 00                	push   $0x0
  pushl $94
c01020d7:	6a 5e                	push   $0x5e
  jmp __alltraps
c01020d9:	e9 97 fc ff ff       	jmp    c0101d75 <__alltraps>

c01020de <vector95>:
.globl vector95
vector95:
  pushl $0
c01020de:	6a 00                	push   $0x0
  pushl $95
c01020e0:	6a 5f                	push   $0x5f
  jmp __alltraps
c01020e2:	e9 8e fc ff ff       	jmp    c0101d75 <__alltraps>

c01020e7 <vector96>:
.globl vector96
vector96:
  pushl $0
c01020e7:	6a 00                	push   $0x0
  pushl $96
c01020e9:	6a 60                	push   $0x60
  jmp __alltraps
c01020eb:	e9 85 fc ff ff       	jmp    c0101d75 <__alltraps>

c01020f0 <vector97>:
.globl vector97
vector97:
  pushl $0
c01020f0:	6a 00                	push   $0x0
  pushl $97
c01020f2:	6a 61                	push   $0x61
  jmp __alltraps
c01020f4:	e9 7c fc ff ff       	jmp    c0101d75 <__alltraps>

c01020f9 <vector98>:
.globl vector98
vector98:
  pushl $0
c01020f9:	6a 00                	push   $0x0
  pushl $98
c01020fb:	6a 62                	push   $0x62
  jmp __alltraps
c01020fd:	e9 73 fc ff ff       	jmp    c0101d75 <__alltraps>

c0102102 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102102:	6a 00                	push   $0x0
  pushl $99
c0102104:	6a 63                	push   $0x63
  jmp __alltraps
c0102106:	e9 6a fc ff ff       	jmp    c0101d75 <__alltraps>

c010210b <vector100>:
.globl vector100
vector100:
  pushl $0
c010210b:	6a 00                	push   $0x0
  pushl $100
c010210d:	6a 64                	push   $0x64
  jmp __alltraps
c010210f:	e9 61 fc ff ff       	jmp    c0101d75 <__alltraps>

c0102114 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102114:	6a 00                	push   $0x0
  pushl $101
c0102116:	6a 65                	push   $0x65
  jmp __alltraps
c0102118:	e9 58 fc ff ff       	jmp    c0101d75 <__alltraps>

c010211d <vector102>:
.globl vector102
vector102:
  pushl $0
c010211d:	6a 00                	push   $0x0
  pushl $102
c010211f:	6a 66                	push   $0x66
  jmp __alltraps
c0102121:	e9 4f fc ff ff       	jmp    c0101d75 <__alltraps>

c0102126 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102126:	6a 00                	push   $0x0
  pushl $103
c0102128:	6a 67                	push   $0x67
  jmp __alltraps
c010212a:	e9 46 fc ff ff       	jmp    c0101d75 <__alltraps>

c010212f <vector104>:
.globl vector104
vector104:
  pushl $0
c010212f:	6a 00                	push   $0x0
  pushl $104
c0102131:	6a 68                	push   $0x68
  jmp __alltraps
c0102133:	e9 3d fc ff ff       	jmp    c0101d75 <__alltraps>

c0102138 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102138:	6a 00                	push   $0x0
  pushl $105
c010213a:	6a 69                	push   $0x69
  jmp __alltraps
c010213c:	e9 34 fc ff ff       	jmp    c0101d75 <__alltraps>

c0102141 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102141:	6a 00                	push   $0x0
  pushl $106
c0102143:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102145:	e9 2b fc ff ff       	jmp    c0101d75 <__alltraps>

c010214a <vector107>:
.globl vector107
vector107:
  pushl $0
c010214a:	6a 00                	push   $0x0
  pushl $107
c010214c:	6a 6b                	push   $0x6b
  jmp __alltraps
c010214e:	e9 22 fc ff ff       	jmp    c0101d75 <__alltraps>

c0102153 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102153:	6a 00                	push   $0x0
  pushl $108
c0102155:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102157:	e9 19 fc ff ff       	jmp    c0101d75 <__alltraps>

c010215c <vector109>:
.globl vector109
vector109:
  pushl $0
c010215c:	6a 00                	push   $0x0
  pushl $109
c010215e:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102160:	e9 10 fc ff ff       	jmp    c0101d75 <__alltraps>

c0102165 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102165:	6a 00                	push   $0x0
  pushl $110
c0102167:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102169:	e9 07 fc ff ff       	jmp    c0101d75 <__alltraps>

c010216e <vector111>:
.globl vector111
vector111:
  pushl $0
c010216e:	6a 00                	push   $0x0
  pushl $111
c0102170:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102172:	e9 fe fb ff ff       	jmp    c0101d75 <__alltraps>

c0102177 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102177:	6a 00                	push   $0x0
  pushl $112
c0102179:	6a 70                	push   $0x70
  jmp __alltraps
c010217b:	e9 f5 fb ff ff       	jmp    c0101d75 <__alltraps>

c0102180 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102180:	6a 00                	push   $0x0
  pushl $113
c0102182:	6a 71                	push   $0x71
  jmp __alltraps
c0102184:	e9 ec fb ff ff       	jmp    c0101d75 <__alltraps>

c0102189 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102189:	6a 00                	push   $0x0
  pushl $114
c010218b:	6a 72                	push   $0x72
  jmp __alltraps
c010218d:	e9 e3 fb ff ff       	jmp    c0101d75 <__alltraps>

c0102192 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102192:	6a 00                	push   $0x0
  pushl $115
c0102194:	6a 73                	push   $0x73
  jmp __alltraps
c0102196:	e9 da fb ff ff       	jmp    c0101d75 <__alltraps>

c010219b <vector116>:
.globl vector116
vector116:
  pushl $0
c010219b:	6a 00                	push   $0x0
  pushl $116
c010219d:	6a 74                	push   $0x74
  jmp __alltraps
c010219f:	e9 d1 fb ff ff       	jmp    c0101d75 <__alltraps>

c01021a4 <vector117>:
.globl vector117
vector117:
  pushl $0
c01021a4:	6a 00                	push   $0x0
  pushl $117
c01021a6:	6a 75                	push   $0x75
  jmp __alltraps
c01021a8:	e9 c8 fb ff ff       	jmp    c0101d75 <__alltraps>

c01021ad <vector118>:
.globl vector118
vector118:
  pushl $0
c01021ad:	6a 00                	push   $0x0
  pushl $118
c01021af:	6a 76                	push   $0x76
  jmp __alltraps
c01021b1:	e9 bf fb ff ff       	jmp    c0101d75 <__alltraps>

c01021b6 <vector119>:
.globl vector119
vector119:
  pushl $0
c01021b6:	6a 00                	push   $0x0
  pushl $119
c01021b8:	6a 77                	push   $0x77
  jmp __alltraps
c01021ba:	e9 b6 fb ff ff       	jmp    c0101d75 <__alltraps>

c01021bf <vector120>:
.globl vector120
vector120:
  pushl $0
c01021bf:	6a 00                	push   $0x0
  pushl $120
c01021c1:	6a 78                	push   $0x78
  jmp __alltraps
c01021c3:	e9 ad fb ff ff       	jmp    c0101d75 <__alltraps>

c01021c8 <vector121>:
.globl vector121
vector121:
  pushl $0
c01021c8:	6a 00                	push   $0x0
  pushl $121
c01021ca:	6a 79                	push   $0x79
  jmp __alltraps
c01021cc:	e9 a4 fb ff ff       	jmp    c0101d75 <__alltraps>

c01021d1 <vector122>:
.globl vector122
vector122:
  pushl $0
c01021d1:	6a 00                	push   $0x0
  pushl $122
c01021d3:	6a 7a                	push   $0x7a
  jmp __alltraps
c01021d5:	e9 9b fb ff ff       	jmp    c0101d75 <__alltraps>

c01021da <vector123>:
.globl vector123
vector123:
  pushl $0
c01021da:	6a 00                	push   $0x0
  pushl $123
c01021dc:	6a 7b                	push   $0x7b
  jmp __alltraps
c01021de:	e9 92 fb ff ff       	jmp    c0101d75 <__alltraps>

c01021e3 <vector124>:
.globl vector124
vector124:
  pushl $0
c01021e3:	6a 00                	push   $0x0
  pushl $124
c01021e5:	6a 7c                	push   $0x7c
  jmp __alltraps
c01021e7:	e9 89 fb ff ff       	jmp    c0101d75 <__alltraps>

c01021ec <vector125>:
.globl vector125
vector125:
  pushl $0
c01021ec:	6a 00                	push   $0x0
  pushl $125
c01021ee:	6a 7d                	push   $0x7d
  jmp __alltraps
c01021f0:	e9 80 fb ff ff       	jmp    c0101d75 <__alltraps>

c01021f5 <vector126>:
.globl vector126
vector126:
  pushl $0
c01021f5:	6a 00                	push   $0x0
  pushl $126
c01021f7:	6a 7e                	push   $0x7e
  jmp __alltraps
c01021f9:	e9 77 fb ff ff       	jmp    c0101d75 <__alltraps>

c01021fe <vector127>:
.globl vector127
vector127:
  pushl $0
c01021fe:	6a 00                	push   $0x0
  pushl $127
c0102200:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102202:	e9 6e fb ff ff       	jmp    c0101d75 <__alltraps>

c0102207 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102207:	6a 00                	push   $0x0
  pushl $128
c0102209:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c010220e:	e9 62 fb ff ff       	jmp    c0101d75 <__alltraps>

c0102213 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102213:	6a 00                	push   $0x0
  pushl $129
c0102215:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c010221a:	e9 56 fb ff ff       	jmp    c0101d75 <__alltraps>

c010221f <vector130>:
.globl vector130
vector130:
  pushl $0
c010221f:	6a 00                	push   $0x0
  pushl $130
c0102221:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102226:	e9 4a fb ff ff       	jmp    c0101d75 <__alltraps>

c010222b <vector131>:
.globl vector131
vector131:
  pushl $0
c010222b:	6a 00                	push   $0x0
  pushl $131
c010222d:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102232:	e9 3e fb ff ff       	jmp    c0101d75 <__alltraps>

c0102237 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102237:	6a 00                	push   $0x0
  pushl $132
c0102239:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c010223e:	e9 32 fb ff ff       	jmp    c0101d75 <__alltraps>

c0102243 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102243:	6a 00                	push   $0x0
  pushl $133
c0102245:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c010224a:	e9 26 fb ff ff       	jmp    c0101d75 <__alltraps>

c010224f <vector134>:
.globl vector134
vector134:
  pushl $0
c010224f:	6a 00                	push   $0x0
  pushl $134
c0102251:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102256:	e9 1a fb ff ff       	jmp    c0101d75 <__alltraps>

c010225b <vector135>:
.globl vector135
vector135:
  pushl $0
c010225b:	6a 00                	push   $0x0
  pushl $135
c010225d:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102262:	e9 0e fb ff ff       	jmp    c0101d75 <__alltraps>

c0102267 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102267:	6a 00                	push   $0x0
  pushl $136
c0102269:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c010226e:	e9 02 fb ff ff       	jmp    c0101d75 <__alltraps>

c0102273 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102273:	6a 00                	push   $0x0
  pushl $137
c0102275:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c010227a:	e9 f6 fa ff ff       	jmp    c0101d75 <__alltraps>

c010227f <vector138>:
.globl vector138
vector138:
  pushl $0
c010227f:	6a 00                	push   $0x0
  pushl $138
c0102281:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102286:	e9 ea fa ff ff       	jmp    c0101d75 <__alltraps>

c010228b <vector139>:
.globl vector139
vector139:
  pushl $0
c010228b:	6a 00                	push   $0x0
  pushl $139
c010228d:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102292:	e9 de fa ff ff       	jmp    c0101d75 <__alltraps>

c0102297 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102297:	6a 00                	push   $0x0
  pushl $140
c0102299:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c010229e:	e9 d2 fa ff ff       	jmp    c0101d75 <__alltraps>

c01022a3 <vector141>:
.globl vector141
vector141:
  pushl $0
c01022a3:	6a 00                	push   $0x0
  pushl $141
c01022a5:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01022aa:	e9 c6 fa ff ff       	jmp    c0101d75 <__alltraps>

c01022af <vector142>:
.globl vector142
vector142:
  pushl $0
c01022af:	6a 00                	push   $0x0
  pushl $142
c01022b1:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01022b6:	e9 ba fa ff ff       	jmp    c0101d75 <__alltraps>

c01022bb <vector143>:
.globl vector143
vector143:
  pushl $0
c01022bb:	6a 00                	push   $0x0
  pushl $143
c01022bd:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01022c2:	e9 ae fa ff ff       	jmp    c0101d75 <__alltraps>

c01022c7 <vector144>:
.globl vector144
vector144:
  pushl $0
c01022c7:	6a 00                	push   $0x0
  pushl $144
c01022c9:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01022ce:	e9 a2 fa ff ff       	jmp    c0101d75 <__alltraps>

c01022d3 <vector145>:
.globl vector145
vector145:
  pushl $0
c01022d3:	6a 00                	push   $0x0
  pushl $145
c01022d5:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01022da:	e9 96 fa ff ff       	jmp    c0101d75 <__alltraps>

c01022df <vector146>:
.globl vector146
vector146:
  pushl $0
c01022df:	6a 00                	push   $0x0
  pushl $146
c01022e1:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01022e6:	e9 8a fa ff ff       	jmp    c0101d75 <__alltraps>

c01022eb <vector147>:
.globl vector147
vector147:
  pushl $0
c01022eb:	6a 00                	push   $0x0
  pushl $147
c01022ed:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c01022f2:	e9 7e fa ff ff       	jmp    c0101d75 <__alltraps>

c01022f7 <vector148>:
.globl vector148
vector148:
  pushl $0
c01022f7:	6a 00                	push   $0x0
  pushl $148
c01022f9:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c01022fe:	e9 72 fa ff ff       	jmp    c0101d75 <__alltraps>

c0102303 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102303:	6a 00                	push   $0x0
  pushl $149
c0102305:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c010230a:	e9 66 fa ff ff       	jmp    c0101d75 <__alltraps>

c010230f <vector150>:
.globl vector150
vector150:
  pushl $0
c010230f:	6a 00                	push   $0x0
  pushl $150
c0102311:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102316:	e9 5a fa ff ff       	jmp    c0101d75 <__alltraps>

c010231b <vector151>:
.globl vector151
vector151:
  pushl $0
c010231b:	6a 00                	push   $0x0
  pushl $151
c010231d:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102322:	e9 4e fa ff ff       	jmp    c0101d75 <__alltraps>

c0102327 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102327:	6a 00                	push   $0x0
  pushl $152
c0102329:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c010232e:	e9 42 fa ff ff       	jmp    c0101d75 <__alltraps>

c0102333 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102333:	6a 00                	push   $0x0
  pushl $153
c0102335:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c010233a:	e9 36 fa ff ff       	jmp    c0101d75 <__alltraps>

c010233f <vector154>:
.globl vector154
vector154:
  pushl $0
c010233f:	6a 00                	push   $0x0
  pushl $154
c0102341:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102346:	e9 2a fa ff ff       	jmp    c0101d75 <__alltraps>

c010234b <vector155>:
.globl vector155
vector155:
  pushl $0
c010234b:	6a 00                	push   $0x0
  pushl $155
c010234d:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102352:	e9 1e fa ff ff       	jmp    c0101d75 <__alltraps>

c0102357 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102357:	6a 00                	push   $0x0
  pushl $156
c0102359:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c010235e:	e9 12 fa ff ff       	jmp    c0101d75 <__alltraps>

c0102363 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102363:	6a 00                	push   $0x0
  pushl $157
c0102365:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c010236a:	e9 06 fa ff ff       	jmp    c0101d75 <__alltraps>

c010236f <vector158>:
.globl vector158
vector158:
  pushl $0
c010236f:	6a 00                	push   $0x0
  pushl $158
c0102371:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102376:	e9 fa f9 ff ff       	jmp    c0101d75 <__alltraps>

c010237b <vector159>:
.globl vector159
vector159:
  pushl $0
c010237b:	6a 00                	push   $0x0
  pushl $159
c010237d:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102382:	e9 ee f9 ff ff       	jmp    c0101d75 <__alltraps>

c0102387 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102387:	6a 00                	push   $0x0
  pushl $160
c0102389:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c010238e:	e9 e2 f9 ff ff       	jmp    c0101d75 <__alltraps>

c0102393 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102393:	6a 00                	push   $0x0
  pushl $161
c0102395:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c010239a:	e9 d6 f9 ff ff       	jmp    c0101d75 <__alltraps>

c010239f <vector162>:
.globl vector162
vector162:
  pushl $0
c010239f:	6a 00                	push   $0x0
  pushl $162
c01023a1:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01023a6:	e9 ca f9 ff ff       	jmp    c0101d75 <__alltraps>

c01023ab <vector163>:
.globl vector163
vector163:
  pushl $0
c01023ab:	6a 00                	push   $0x0
  pushl $163
c01023ad:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01023b2:	e9 be f9 ff ff       	jmp    c0101d75 <__alltraps>

c01023b7 <vector164>:
.globl vector164
vector164:
  pushl $0
c01023b7:	6a 00                	push   $0x0
  pushl $164
c01023b9:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01023be:	e9 b2 f9 ff ff       	jmp    c0101d75 <__alltraps>

c01023c3 <vector165>:
.globl vector165
vector165:
  pushl $0
c01023c3:	6a 00                	push   $0x0
  pushl $165
c01023c5:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01023ca:	e9 a6 f9 ff ff       	jmp    c0101d75 <__alltraps>

c01023cf <vector166>:
.globl vector166
vector166:
  pushl $0
c01023cf:	6a 00                	push   $0x0
  pushl $166
c01023d1:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01023d6:	e9 9a f9 ff ff       	jmp    c0101d75 <__alltraps>

c01023db <vector167>:
.globl vector167
vector167:
  pushl $0
c01023db:	6a 00                	push   $0x0
  pushl $167
c01023dd:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01023e2:	e9 8e f9 ff ff       	jmp    c0101d75 <__alltraps>

c01023e7 <vector168>:
.globl vector168
vector168:
  pushl $0
c01023e7:	6a 00                	push   $0x0
  pushl $168
c01023e9:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01023ee:	e9 82 f9 ff ff       	jmp    c0101d75 <__alltraps>

c01023f3 <vector169>:
.globl vector169
vector169:
  pushl $0
c01023f3:	6a 00                	push   $0x0
  pushl $169
c01023f5:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01023fa:	e9 76 f9 ff ff       	jmp    c0101d75 <__alltraps>

c01023ff <vector170>:
.globl vector170
vector170:
  pushl $0
c01023ff:	6a 00                	push   $0x0
  pushl $170
c0102401:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102406:	e9 6a f9 ff ff       	jmp    c0101d75 <__alltraps>

c010240b <vector171>:
.globl vector171
vector171:
  pushl $0
c010240b:	6a 00                	push   $0x0
  pushl $171
c010240d:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102412:	e9 5e f9 ff ff       	jmp    c0101d75 <__alltraps>

c0102417 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102417:	6a 00                	push   $0x0
  pushl $172
c0102419:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c010241e:	e9 52 f9 ff ff       	jmp    c0101d75 <__alltraps>

c0102423 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102423:	6a 00                	push   $0x0
  pushl $173
c0102425:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c010242a:	e9 46 f9 ff ff       	jmp    c0101d75 <__alltraps>

c010242f <vector174>:
.globl vector174
vector174:
  pushl $0
c010242f:	6a 00                	push   $0x0
  pushl $174
c0102431:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102436:	e9 3a f9 ff ff       	jmp    c0101d75 <__alltraps>

c010243b <vector175>:
.globl vector175
vector175:
  pushl $0
c010243b:	6a 00                	push   $0x0
  pushl $175
c010243d:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102442:	e9 2e f9 ff ff       	jmp    c0101d75 <__alltraps>

c0102447 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102447:	6a 00                	push   $0x0
  pushl $176
c0102449:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c010244e:	e9 22 f9 ff ff       	jmp    c0101d75 <__alltraps>

c0102453 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102453:	6a 00                	push   $0x0
  pushl $177
c0102455:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c010245a:	e9 16 f9 ff ff       	jmp    c0101d75 <__alltraps>

c010245f <vector178>:
.globl vector178
vector178:
  pushl $0
c010245f:	6a 00                	push   $0x0
  pushl $178
c0102461:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102466:	e9 0a f9 ff ff       	jmp    c0101d75 <__alltraps>

c010246b <vector179>:
.globl vector179
vector179:
  pushl $0
c010246b:	6a 00                	push   $0x0
  pushl $179
c010246d:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102472:	e9 fe f8 ff ff       	jmp    c0101d75 <__alltraps>

c0102477 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102477:	6a 00                	push   $0x0
  pushl $180
c0102479:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010247e:	e9 f2 f8 ff ff       	jmp    c0101d75 <__alltraps>

c0102483 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102483:	6a 00                	push   $0x0
  pushl $181
c0102485:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c010248a:	e9 e6 f8 ff ff       	jmp    c0101d75 <__alltraps>

c010248f <vector182>:
.globl vector182
vector182:
  pushl $0
c010248f:	6a 00                	push   $0x0
  pushl $182
c0102491:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102496:	e9 da f8 ff ff       	jmp    c0101d75 <__alltraps>

c010249b <vector183>:
.globl vector183
vector183:
  pushl $0
c010249b:	6a 00                	push   $0x0
  pushl $183
c010249d:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01024a2:	e9 ce f8 ff ff       	jmp    c0101d75 <__alltraps>

c01024a7 <vector184>:
.globl vector184
vector184:
  pushl $0
c01024a7:	6a 00                	push   $0x0
  pushl $184
c01024a9:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01024ae:	e9 c2 f8 ff ff       	jmp    c0101d75 <__alltraps>

c01024b3 <vector185>:
.globl vector185
vector185:
  pushl $0
c01024b3:	6a 00                	push   $0x0
  pushl $185
c01024b5:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01024ba:	e9 b6 f8 ff ff       	jmp    c0101d75 <__alltraps>

c01024bf <vector186>:
.globl vector186
vector186:
  pushl $0
c01024bf:	6a 00                	push   $0x0
  pushl $186
c01024c1:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01024c6:	e9 aa f8 ff ff       	jmp    c0101d75 <__alltraps>

c01024cb <vector187>:
.globl vector187
vector187:
  pushl $0
c01024cb:	6a 00                	push   $0x0
  pushl $187
c01024cd:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01024d2:	e9 9e f8 ff ff       	jmp    c0101d75 <__alltraps>

c01024d7 <vector188>:
.globl vector188
vector188:
  pushl $0
c01024d7:	6a 00                	push   $0x0
  pushl $188
c01024d9:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01024de:	e9 92 f8 ff ff       	jmp    c0101d75 <__alltraps>

c01024e3 <vector189>:
.globl vector189
vector189:
  pushl $0
c01024e3:	6a 00                	push   $0x0
  pushl $189
c01024e5:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01024ea:	e9 86 f8 ff ff       	jmp    c0101d75 <__alltraps>

c01024ef <vector190>:
.globl vector190
vector190:
  pushl $0
c01024ef:	6a 00                	push   $0x0
  pushl $190
c01024f1:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01024f6:	e9 7a f8 ff ff       	jmp    c0101d75 <__alltraps>

c01024fb <vector191>:
.globl vector191
vector191:
  pushl $0
c01024fb:	6a 00                	push   $0x0
  pushl $191
c01024fd:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102502:	e9 6e f8 ff ff       	jmp    c0101d75 <__alltraps>

c0102507 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102507:	6a 00                	push   $0x0
  pushl $192
c0102509:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c010250e:	e9 62 f8 ff ff       	jmp    c0101d75 <__alltraps>

c0102513 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102513:	6a 00                	push   $0x0
  pushl $193
c0102515:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c010251a:	e9 56 f8 ff ff       	jmp    c0101d75 <__alltraps>

c010251f <vector194>:
.globl vector194
vector194:
  pushl $0
c010251f:	6a 00                	push   $0x0
  pushl $194
c0102521:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102526:	e9 4a f8 ff ff       	jmp    c0101d75 <__alltraps>

c010252b <vector195>:
.globl vector195
vector195:
  pushl $0
c010252b:	6a 00                	push   $0x0
  pushl $195
c010252d:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102532:	e9 3e f8 ff ff       	jmp    c0101d75 <__alltraps>

c0102537 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102537:	6a 00                	push   $0x0
  pushl $196
c0102539:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c010253e:	e9 32 f8 ff ff       	jmp    c0101d75 <__alltraps>

c0102543 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102543:	6a 00                	push   $0x0
  pushl $197
c0102545:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c010254a:	e9 26 f8 ff ff       	jmp    c0101d75 <__alltraps>

c010254f <vector198>:
.globl vector198
vector198:
  pushl $0
c010254f:	6a 00                	push   $0x0
  pushl $198
c0102551:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102556:	e9 1a f8 ff ff       	jmp    c0101d75 <__alltraps>

c010255b <vector199>:
.globl vector199
vector199:
  pushl $0
c010255b:	6a 00                	push   $0x0
  pushl $199
c010255d:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102562:	e9 0e f8 ff ff       	jmp    c0101d75 <__alltraps>

c0102567 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102567:	6a 00                	push   $0x0
  pushl $200
c0102569:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c010256e:	e9 02 f8 ff ff       	jmp    c0101d75 <__alltraps>

c0102573 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102573:	6a 00                	push   $0x0
  pushl $201
c0102575:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c010257a:	e9 f6 f7 ff ff       	jmp    c0101d75 <__alltraps>

c010257f <vector202>:
.globl vector202
vector202:
  pushl $0
c010257f:	6a 00                	push   $0x0
  pushl $202
c0102581:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102586:	e9 ea f7 ff ff       	jmp    c0101d75 <__alltraps>

c010258b <vector203>:
.globl vector203
vector203:
  pushl $0
c010258b:	6a 00                	push   $0x0
  pushl $203
c010258d:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102592:	e9 de f7 ff ff       	jmp    c0101d75 <__alltraps>

c0102597 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102597:	6a 00                	push   $0x0
  pushl $204
c0102599:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c010259e:	e9 d2 f7 ff ff       	jmp    c0101d75 <__alltraps>

c01025a3 <vector205>:
.globl vector205
vector205:
  pushl $0
c01025a3:	6a 00                	push   $0x0
  pushl $205
c01025a5:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01025aa:	e9 c6 f7 ff ff       	jmp    c0101d75 <__alltraps>

c01025af <vector206>:
.globl vector206
vector206:
  pushl $0
c01025af:	6a 00                	push   $0x0
  pushl $206
c01025b1:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01025b6:	e9 ba f7 ff ff       	jmp    c0101d75 <__alltraps>

c01025bb <vector207>:
.globl vector207
vector207:
  pushl $0
c01025bb:	6a 00                	push   $0x0
  pushl $207
c01025bd:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01025c2:	e9 ae f7 ff ff       	jmp    c0101d75 <__alltraps>

c01025c7 <vector208>:
.globl vector208
vector208:
  pushl $0
c01025c7:	6a 00                	push   $0x0
  pushl $208
c01025c9:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01025ce:	e9 a2 f7 ff ff       	jmp    c0101d75 <__alltraps>

c01025d3 <vector209>:
.globl vector209
vector209:
  pushl $0
c01025d3:	6a 00                	push   $0x0
  pushl $209
c01025d5:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01025da:	e9 96 f7 ff ff       	jmp    c0101d75 <__alltraps>

c01025df <vector210>:
.globl vector210
vector210:
  pushl $0
c01025df:	6a 00                	push   $0x0
  pushl $210
c01025e1:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01025e6:	e9 8a f7 ff ff       	jmp    c0101d75 <__alltraps>

c01025eb <vector211>:
.globl vector211
vector211:
  pushl $0
c01025eb:	6a 00                	push   $0x0
  pushl $211
c01025ed:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01025f2:	e9 7e f7 ff ff       	jmp    c0101d75 <__alltraps>

c01025f7 <vector212>:
.globl vector212
vector212:
  pushl $0
c01025f7:	6a 00                	push   $0x0
  pushl $212
c01025f9:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01025fe:	e9 72 f7 ff ff       	jmp    c0101d75 <__alltraps>

c0102603 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102603:	6a 00                	push   $0x0
  pushl $213
c0102605:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c010260a:	e9 66 f7 ff ff       	jmp    c0101d75 <__alltraps>

c010260f <vector214>:
.globl vector214
vector214:
  pushl $0
c010260f:	6a 00                	push   $0x0
  pushl $214
c0102611:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102616:	e9 5a f7 ff ff       	jmp    c0101d75 <__alltraps>

c010261b <vector215>:
.globl vector215
vector215:
  pushl $0
c010261b:	6a 00                	push   $0x0
  pushl $215
c010261d:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102622:	e9 4e f7 ff ff       	jmp    c0101d75 <__alltraps>

c0102627 <vector216>:
.globl vector216
vector216:
  pushl $0
c0102627:	6a 00                	push   $0x0
  pushl $216
c0102629:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c010262e:	e9 42 f7 ff ff       	jmp    c0101d75 <__alltraps>

c0102633 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102633:	6a 00                	push   $0x0
  pushl $217
c0102635:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c010263a:	e9 36 f7 ff ff       	jmp    c0101d75 <__alltraps>

c010263f <vector218>:
.globl vector218
vector218:
  pushl $0
c010263f:	6a 00                	push   $0x0
  pushl $218
c0102641:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102646:	e9 2a f7 ff ff       	jmp    c0101d75 <__alltraps>

c010264b <vector219>:
.globl vector219
vector219:
  pushl $0
c010264b:	6a 00                	push   $0x0
  pushl $219
c010264d:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102652:	e9 1e f7 ff ff       	jmp    c0101d75 <__alltraps>

c0102657 <vector220>:
.globl vector220
vector220:
  pushl $0
c0102657:	6a 00                	push   $0x0
  pushl $220
c0102659:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c010265e:	e9 12 f7 ff ff       	jmp    c0101d75 <__alltraps>

c0102663 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102663:	6a 00                	push   $0x0
  pushl $221
c0102665:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c010266a:	e9 06 f7 ff ff       	jmp    c0101d75 <__alltraps>

c010266f <vector222>:
.globl vector222
vector222:
  pushl $0
c010266f:	6a 00                	push   $0x0
  pushl $222
c0102671:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102676:	e9 fa f6 ff ff       	jmp    c0101d75 <__alltraps>

c010267b <vector223>:
.globl vector223
vector223:
  pushl $0
c010267b:	6a 00                	push   $0x0
  pushl $223
c010267d:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102682:	e9 ee f6 ff ff       	jmp    c0101d75 <__alltraps>

c0102687 <vector224>:
.globl vector224
vector224:
  pushl $0
c0102687:	6a 00                	push   $0x0
  pushl $224
c0102689:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010268e:	e9 e2 f6 ff ff       	jmp    c0101d75 <__alltraps>

c0102693 <vector225>:
.globl vector225
vector225:
  pushl $0
c0102693:	6a 00                	push   $0x0
  pushl $225
c0102695:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c010269a:	e9 d6 f6 ff ff       	jmp    c0101d75 <__alltraps>

c010269f <vector226>:
.globl vector226
vector226:
  pushl $0
c010269f:	6a 00                	push   $0x0
  pushl $226
c01026a1:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01026a6:	e9 ca f6 ff ff       	jmp    c0101d75 <__alltraps>

c01026ab <vector227>:
.globl vector227
vector227:
  pushl $0
c01026ab:	6a 00                	push   $0x0
  pushl $227
c01026ad:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01026b2:	e9 be f6 ff ff       	jmp    c0101d75 <__alltraps>

c01026b7 <vector228>:
.globl vector228
vector228:
  pushl $0
c01026b7:	6a 00                	push   $0x0
  pushl $228
c01026b9:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01026be:	e9 b2 f6 ff ff       	jmp    c0101d75 <__alltraps>

c01026c3 <vector229>:
.globl vector229
vector229:
  pushl $0
c01026c3:	6a 00                	push   $0x0
  pushl $229
c01026c5:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01026ca:	e9 a6 f6 ff ff       	jmp    c0101d75 <__alltraps>

c01026cf <vector230>:
.globl vector230
vector230:
  pushl $0
c01026cf:	6a 00                	push   $0x0
  pushl $230
c01026d1:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01026d6:	e9 9a f6 ff ff       	jmp    c0101d75 <__alltraps>

c01026db <vector231>:
.globl vector231
vector231:
  pushl $0
c01026db:	6a 00                	push   $0x0
  pushl $231
c01026dd:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01026e2:	e9 8e f6 ff ff       	jmp    c0101d75 <__alltraps>

c01026e7 <vector232>:
.globl vector232
vector232:
  pushl $0
c01026e7:	6a 00                	push   $0x0
  pushl $232
c01026e9:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01026ee:	e9 82 f6 ff ff       	jmp    c0101d75 <__alltraps>

c01026f3 <vector233>:
.globl vector233
vector233:
  pushl $0
c01026f3:	6a 00                	push   $0x0
  pushl $233
c01026f5:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01026fa:	e9 76 f6 ff ff       	jmp    c0101d75 <__alltraps>

c01026ff <vector234>:
.globl vector234
vector234:
  pushl $0
c01026ff:	6a 00                	push   $0x0
  pushl $234
c0102701:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102706:	e9 6a f6 ff ff       	jmp    c0101d75 <__alltraps>

c010270b <vector235>:
.globl vector235
vector235:
  pushl $0
c010270b:	6a 00                	push   $0x0
  pushl $235
c010270d:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102712:	e9 5e f6 ff ff       	jmp    c0101d75 <__alltraps>

c0102717 <vector236>:
.globl vector236
vector236:
  pushl $0
c0102717:	6a 00                	push   $0x0
  pushl $236
c0102719:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c010271e:	e9 52 f6 ff ff       	jmp    c0101d75 <__alltraps>

c0102723 <vector237>:
.globl vector237
vector237:
  pushl $0
c0102723:	6a 00                	push   $0x0
  pushl $237
c0102725:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010272a:	e9 46 f6 ff ff       	jmp    c0101d75 <__alltraps>

c010272f <vector238>:
.globl vector238
vector238:
  pushl $0
c010272f:	6a 00                	push   $0x0
  pushl $238
c0102731:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102736:	e9 3a f6 ff ff       	jmp    c0101d75 <__alltraps>

c010273b <vector239>:
.globl vector239
vector239:
  pushl $0
c010273b:	6a 00                	push   $0x0
  pushl $239
c010273d:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102742:	e9 2e f6 ff ff       	jmp    c0101d75 <__alltraps>

c0102747 <vector240>:
.globl vector240
vector240:
  pushl $0
c0102747:	6a 00                	push   $0x0
  pushl $240
c0102749:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c010274e:	e9 22 f6 ff ff       	jmp    c0101d75 <__alltraps>

c0102753 <vector241>:
.globl vector241
vector241:
  pushl $0
c0102753:	6a 00                	push   $0x0
  pushl $241
c0102755:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c010275a:	e9 16 f6 ff ff       	jmp    c0101d75 <__alltraps>

c010275f <vector242>:
.globl vector242
vector242:
  pushl $0
c010275f:	6a 00                	push   $0x0
  pushl $242
c0102761:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0102766:	e9 0a f6 ff ff       	jmp    c0101d75 <__alltraps>

c010276b <vector243>:
.globl vector243
vector243:
  pushl $0
c010276b:	6a 00                	push   $0x0
  pushl $243
c010276d:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0102772:	e9 fe f5 ff ff       	jmp    c0101d75 <__alltraps>

c0102777 <vector244>:
.globl vector244
vector244:
  pushl $0
c0102777:	6a 00                	push   $0x0
  pushl $244
c0102779:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010277e:	e9 f2 f5 ff ff       	jmp    c0101d75 <__alltraps>

c0102783 <vector245>:
.globl vector245
vector245:
  pushl $0
c0102783:	6a 00                	push   $0x0
  pushl $245
c0102785:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c010278a:	e9 e6 f5 ff ff       	jmp    c0101d75 <__alltraps>

c010278f <vector246>:
.globl vector246
vector246:
  pushl $0
c010278f:	6a 00                	push   $0x0
  pushl $246
c0102791:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102796:	e9 da f5 ff ff       	jmp    c0101d75 <__alltraps>

c010279b <vector247>:
.globl vector247
vector247:
  pushl $0
c010279b:	6a 00                	push   $0x0
  pushl $247
c010279d:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01027a2:	e9 ce f5 ff ff       	jmp    c0101d75 <__alltraps>

c01027a7 <vector248>:
.globl vector248
vector248:
  pushl $0
c01027a7:	6a 00                	push   $0x0
  pushl $248
c01027a9:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01027ae:	e9 c2 f5 ff ff       	jmp    c0101d75 <__alltraps>

c01027b3 <vector249>:
.globl vector249
vector249:
  pushl $0
c01027b3:	6a 00                	push   $0x0
  pushl $249
c01027b5:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01027ba:	e9 b6 f5 ff ff       	jmp    c0101d75 <__alltraps>

c01027bf <vector250>:
.globl vector250
vector250:
  pushl $0
c01027bf:	6a 00                	push   $0x0
  pushl $250
c01027c1:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01027c6:	e9 aa f5 ff ff       	jmp    c0101d75 <__alltraps>

c01027cb <vector251>:
.globl vector251
vector251:
  pushl $0
c01027cb:	6a 00                	push   $0x0
  pushl $251
c01027cd:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01027d2:	e9 9e f5 ff ff       	jmp    c0101d75 <__alltraps>

c01027d7 <vector252>:
.globl vector252
vector252:
  pushl $0
c01027d7:	6a 00                	push   $0x0
  pushl $252
c01027d9:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01027de:	e9 92 f5 ff ff       	jmp    c0101d75 <__alltraps>

c01027e3 <vector253>:
.globl vector253
vector253:
  pushl $0
c01027e3:	6a 00                	push   $0x0
  pushl $253
c01027e5:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01027ea:	e9 86 f5 ff ff       	jmp    c0101d75 <__alltraps>

c01027ef <vector254>:
.globl vector254
vector254:
  pushl $0
c01027ef:	6a 00                	push   $0x0
  pushl $254
c01027f1:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01027f6:	e9 7a f5 ff ff       	jmp    c0101d75 <__alltraps>

c01027fb <vector255>:
.globl vector255
vector255:
  pushl $0
c01027fb:	6a 00                	push   $0x0
  pushl $255
c01027fd:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102802:	e9 6e f5 ff ff       	jmp    c0101d75 <__alltraps>

c0102807 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0102807:	55                   	push   %ebp
c0102808:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010280a:	8b 55 08             	mov    0x8(%ebp),%edx
c010280d:	a1 64 89 11 c0       	mov    0xc0118964,%eax
c0102812:	29 c2                	sub    %eax,%edx
c0102814:	89 d0                	mov    %edx,%eax
c0102816:	c1 f8 02             	sar    $0x2,%eax
c0102819:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c010281f:	5d                   	pop    %ebp
c0102820:	c3                   	ret    

c0102821 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102821:	55                   	push   %ebp
c0102822:	89 e5                	mov    %esp,%ebp
c0102824:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102827:	8b 45 08             	mov    0x8(%ebp),%eax
c010282a:	89 04 24             	mov    %eax,(%esp)
c010282d:	e8 d5 ff ff ff       	call   c0102807 <page2ppn>
c0102832:	c1 e0 0c             	shl    $0xc,%eax
}
c0102835:	c9                   	leave  
c0102836:	c3                   	ret    

c0102837 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0102837:	55                   	push   %ebp
c0102838:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010283a:	8b 45 08             	mov    0x8(%ebp),%eax
c010283d:	8b 00                	mov    (%eax),%eax
}
c010283f:	5d                   	pop    %ebp
c0102840:	c3                   	ret    

c0102841 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102841:	55                   	push   %ebp
c0102842:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102844:	8b 45 08             	mov    0x8(%ebp),%eax
c0102847:	8b 55 0c             	mov    0xc(%ebp),%edx
c010284a:	89 10                	mov    %edx,(%eax)
}
c010284c:	5d                   	pop    %ebp
c010284d:	c3                   	ret    

c010284e <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c010284e:	55                   	push   %ebp
c010284f:	89 e5                	mov    %esp,%ebp
c0102851:	83 ec 10             	sub    $0x10,%esp
c0102854:	c7 45 fc 50 89 11 c0 	movl   $0xc0118950,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010285b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010285e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0102861:	89 50 04             	mov    %edx,0x4(%eax)
c0102864:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102867:	8b 50 04             	mov    0x4(%eax),%edx
c010286a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010286d:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c010286f:	c7 05 58 89 11 c0 00 	movl   $0x0,0xc0118958
c0102876:	00 00 00 
}
c0102879:	c9                   	leave  
c010287a:	c3                   	ret    

c010287b <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c010287b:	55                   	push   %ebp
c010287c:	89 e5                	mov    %esp,%ebp
c010287e:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0102881:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102885:	75 24                	jne    c01028ab <default_init_memmap+0x30>
c0102887:	c7 44 24 0c d0 65 10 	movl   $0xc01065d0,0xc(%esp)
c010288e:	c0 
c010288f:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102896:	c0 
c0102897:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
c010289e:	00 
c010289f:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01028a6:	e8 1b e4 ff ff       	call   c0100cc6 <__panic>
    struct Page *p = base;
c01028ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01028ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01028b1:	e9 dc 00 00 00       	jmp    c0102992 <default_init_memmap+0x117>
        assert(PageReserved(p));
c01028b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028b9:	83 c0 04             	add    $0x4,%eax
c01028bc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01028c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01028c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01028c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01028cc:	0f a3 10             	bt     %edx,(%eax)
c01028cf:	19 c0                	sbb    %eax,%eax
c01028d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01028d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01028d8:	0f 95 c0             	setne  %al
c01028db:	0f b6 c0             	movzbl %al,%eax
c01028de:	85 c0                	test   %eax,%eax
c01028e0:	75 24                	jne    c0102906 <default_init_memmap+0x8b>
c01028e2:	c7 44 24 0c 01 66 10 	movl   $0xc0106601,0xc(%esp)
c01028e9:	c0 
c01028ea:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01028f1:	c0 
c01028f2:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
c01028f9:	00 
c01028fa:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102901:	e8 c0 e3 ff ff       	call   c0100cc6 <__panic>
        p->flags = 0;
c0102906:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102909:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        SetPageProperty(p);
c0102910:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102913:	83 c0 04             	add    $0x4,%eax
c0102916:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c010291d:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102920:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102923:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102926:	0f ab 10             	bts    %edx,(%eax)
        p->property = 0;
c0102929:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010292c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        set_page_ref(p, 0);
c0102933:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010293a:	00 
c010293b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010293e:	89 04 24             	mov    %eax,(%esp)
c0102941:	e8 fb fe ff ff       	call   c0102841 <set_page_ref>
        list_add_before(&free_list, &(p->page_link));
c0102946:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102949:	83 c0 0c             	add    $0xc,%eax
c010294c:	c7 45 dc 50 89 11 c0 	movl   $0xc0118950,-0x24(%ebp)
c0102953:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0102956:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102959:	8b 00                	mov    (%eax),%eax
c010295b:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010295e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102961:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102964:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102967:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010296a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010296d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102970:	89 10                	mov    %edx,(%eax)
c0102972:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102975:	8b 10                	mov    (%eax),%edx
c0102977:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010297a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010297d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102980:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102983:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102986:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102989:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010298c:	89 10                	mov    %edx,(%eax)

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c010298e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102992:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102995:	89 d0                	mov    %edx,%eax
c0102997:	c1 e0 02             	shl    $0x2,%eax
c010299a:	01 d0                	add    %edx,%eax
c010299c:	c1 e0 02             	shl    $0x2,%eax
c010299f:	89 c2                	mov    %eax,%edx
c01029a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01029a4:	01 d0                	add    %edx,%eax
c01029a6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01029a9:	0f 85 07 ff ff ff    	jne    c01028b6 <default_init_memmap+0x3b>
        SetPageProperty(p);
        p->property = 0;
        set_page_ref(p, 0);
        list_add_before(&free_list, &(p->page_link));
    }
    nr_free += n;
c01029af:	8b 15 58 89 11 c0    	mov    0xc0118958,%edx
c01029b5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01029b8:	01 d0                	add    %edx,%eax
c01029ba:	a3 58 89 11 c0       	mov    %eax,0xc0118958
    //first block
    base->property = n;
c01029bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01029c2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01029c5:	89 50 08             	mov    %edx,0x8(%eax)
}
c01029c8:	c9                   	leave  
c01029c9:	c3                   	ret    

c01029ca <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01029ca:	55                   	push   %ebp
c01029cb:	89 e5                	mov    %esp,%ebp
c01029cd:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01029d0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01029d4:	75 24                	jne    c01029fa <default_alloc_pages+0x30>
c01029d6:	c7 44 24 0c d0 65 10 	movl   $0xc01065d0,0xc(%esp)
c01029dd:	c0 
c01029de:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01029e5:	c0 
c01029e6:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
c01029ed:	00 
c01029ee:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01029f5:	e8 cc e2 ff ff       	call   c0100cc6 <__panic>
    if (n > nr_free) {
c01029fa:	a1 58 89 11 c0       	mov    0xc0118958,%eax
c01029ff:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102a02:	73 0a                	jae    c0102a0e <default_alloc_pages+0x44>
        return NULL;
c0102a04:	b8 00 00 00 00       	mov    $0x0,%eax
c0102a09:	e9 37 01 00 00       	jmp    c0102b45 <default_alloc_pages+0x17b>
    }
    list_entry_t *le, *len;
    le = &free_list;
c0102a0e:	c7 45 f4 50 89 11 c0 	movl   $0xc0118950,-0xc(%ebp)

    while((le=list_next(le)) != &free_list) {
c0102a15:	e9 0a 01 00 00       	jmp    c0102b24 <default_alloc_pages+0x15a>
      struct Page *p = le2page(le, page_link);
c0102a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a1d:	83 e8 0c             	sub    $0xc,%eax
c0102a20:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(p->property >= n){
c0102a23:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102a26:	8b 40 08             	mov    0x8(%eax),%eax
c0102a29:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102a2c:	0f 82 f2 00 00 00    	jb     c0102b24 <default_alloc_pages+0x15a>
        int i;
        for(i=0;i<n;i++){
c0102a32:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0102a39:	eb 7c                	jmp    c0102ab7 <default_alloc_pages+0xed>
c0102a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a3e:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102a41:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102a44:	8b 40 04             	mov    0x4(%eax),%eax
          len = list_next(le);
c0102a47:	89 45 e8             	mov    %eax,-0x18(%ebp)
          struct Page *pp = le2page(le, page_link);
c0102a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a4d:	83 e8 0c             	sub    $0xc,%eax
c0102a50:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          SetPageReserved(pp);
c0102a53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102a56:	83 c0 04             	add    $0x4,%eax
c0102a59:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102a60:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0102a63:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102a66:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102a69:	0f ab 10             	bts    %edx,(%eax)
          ClearPageProperty(pp);
c0102a6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102a6f:	83 c0 04             	add    $0x4,%eax
c0102a72:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0102a79:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102a7c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102a7f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102a82:	0f b3 10             	btr    %edx,(%eax)
c0102a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102a88:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102a8b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102a8e:	8b 40 04             	mov    0x4(%eax),%eax
c0102a91:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102a94:	8b 12                	mov    (%edx),%edx
c0102a96:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0102a99:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102a9c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102a9f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102aa2:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102aa5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102aa8:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102aab:	89 10                	mov    %edx,(%eax)
          list_del(le);
          le = len;
c0102aad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102ab0:	89 45 f4             	mov    %eax,-0xc(%ebp)

    while((le=list_next(le)) != &free_list) {
      struct Page *p = le2page(le, page_link);
      if(p->property >= n){
        int i;
        for(i=0;i<n;i++){
c0102ab3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
c0102ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102aba:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102abd:	0f 82 78 ff ff ff    	jb     c0102a3b <default_alloc_pages+0x71>
          SetPageReserved(pp);
          ClearPageProperty(pp);
          list_del(le);
          le = len;
        }
        if(p->property>n){
c0102ac3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102ac6:	8b 40 08             	mov    0x8(%eax),%eax
c0102ac9:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102acc:	76 12                	jbe    c0102ae0 <default_alloc_pages+0x116>
          (le2page(le,page_link))->property = p->property - n;
c0102ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ad1:	8d 50 f4             	lea    -0xc(%eax),%edx
c0102ad4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102ad7:	8b 40 08             	mov    0x8(%eax),%eax
c0102ada:	2b 45 08             	sub    0x8(%ebp),%eax
c0102add:	89 42 08             	mov    %eax,0x8(%edx)
        }
        ClearPageProperty(p);
c0102ae0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102ae3:	83 c0 04             	add    $0x4,%eax
c0102ae6:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0102aed:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0102af0:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102af3:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102af6:	0f b3 10             	btr    %edx,(%eax)
        SetPageReserved(p);
c0102af9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102afc:	83 c0 04             	add    $0x4,%eax
c0102aff:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
c0102b06:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102b09:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102b0c:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102b0f:	0f ab 10             	bts    %edx,(%eax)
        nr_free -= n;
c0102b12:	a1 58 89 11 c0       	mov    0xc0118958,%eax
c0102b17:	2b 45 08             	sub    0x8(%ebp),%eax
c0102b1a:	a3 58 89 11 c0       	mov    %eax,0xc0118958
        return p;
c0102b1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102b22:	eb 21                	jmp    c0102b45 <default_alloc_pages+0x17b>
c0102b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b27:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102b2a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102b2d:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    list_entry_t *le, *len;
    le = &free_list;

    while((le=list_next(le)) != &free_list) {
c0102b30:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102b33:	81 7d f4 50 89 11 c0 	cmpl   $0xc0118950,-0xc(%ebp)
c0102b3a:	0f 85 da fe ff ff    	jne    c0102a1a <default_alloc_pages+0x50>
        SetPageReserved(p);
        nr_free -= n;
        return p;
      }
    }
    return NULL;
c0102b40:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102b45:	c9                   	leave  
c0102b46:	c3                   	ret    

c0102b47 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0102b47:	55                   	push   %ebp
c0102b48:	89 e5                	mov    %esp,%ebp
c0102b4a:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0102b4d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102b51:	75 24                	jne    c0102b77 <default_free_pages+0x30>
c0102b53:	c7 44 24 0c d0 65 10 	movl   $0xc01065d0,0xc(%esp)
c0102b5a:	c0 
c0102b5b:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102b62:	c0 
c0102b63:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
c0102b6a:	00 
c0102b6b:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102b72:	e8 4f e1 ff ff       	call   c0100cc6 <__panic>
    assert(PageReserved(base));
c0102b77:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b7a:	83 c0 04             	add    $0x4,%eax
c0102b7d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102b84:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102b87:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102b8a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102b8d:	0f a3 10             	bt     %edx,(%eax)
c0102b90:	19 c0                	sbb    %eax,%eax
c0102b92:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0102b95:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102b99:	0f 95 c0             	setne  %al
c0102b9c:	0f b6 c0             	movzbl %al,%eax
c0102b9f:	85 c0                	test   %eax,%eax
c0102ba1:	75 24                	jne    c0102bc7 <default_free_pages+0x80>
c0102ba3:	c7 44 24 0c 11 66 10 	movl   $0xc0106611,0xc(%esp)
c0102baa:	c0 
c0102bab:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102bb2:	c0 
c0102bb3:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
c0102bba:	00 
c0102bbb:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102bc2:	e8 ff e0 ff ff       	call   c0100cc6 <__panic>

    list_entry_t *le = &free_list;
c0102bc7:	c7 45 f4 50 89 11 c0 	movl   $0xc0118950,-0xc(%ebp)
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
c0102bce:	eb 13                	jmp    c0102be3 <default_free_pages+0x9c>
      p = le2page(le, page_link);
c0102bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102bd3:	83 e8 0c             	sub    $0xc,%eax
c0102bd6:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(p>base){
c0102bd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102bdc:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102bdf:	76 02                	jbe    c0102be3 <default_free_pages+0x9c>
        break;
c0102be1:	eb 18                	jmp    c0102bfb <default_free_pages+0xb4>
c0102be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102be6:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102be9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102bec:	8b 40 04             	mov    0x4(%eax),%eax
    assert(n > 0);
    assert(PageReserved(base));

    list_entry_t *le = &free_list;
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
c0102bef:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102bf2:	81 7d f4 50 89 11 c0 	cmpl   $0xc0118950,-0xc(%ebp)
c0102bf9:	75 d5                	jne    c0102bd0 <default_free_pages+0x89>
      if(p>base){
        break;
      }
    }
    //list_add_before(le, base->page_link);
    for(p=base;p<base+n;p++){
c0102bfb:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102c01:	eb 4b                	jmp    c0102c4e <default_free_pages+0x107>
      list_add_before(le, &(p->page_link));
c0102c03:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102c06:	8d 50 0c             	lea    0xc(%eax),%edx
c0102c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c0c:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0102c0f:	89 55 d8             	mov    %edx,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0102c12:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102c15:	8b 00                	mov    (%eax),%eax
c0102c17:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102c1a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102c1d:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102c20:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102c23:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102c26:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102c29:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102c2c:	89 10                	mov    %edx,(%eax)
c0102c2e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102c31:	8b 10                	mov    (%eax),%edx
c0102c33:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102c36:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102c39:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102c3c:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102c3f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102c42:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102c45:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102c48:	89 10                	mov    %edx,(%eax)
      if(p>base){
        break;
      }
    }
    //list_add_before(le, base->page_link);
    for(p=base;p<base+n;p++){
c0102c4a:	83 45 f0 14          	addl   $0x14,-0x10(%ebp)
c0102c4e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102c51:	89 d0                	mov    %edx,%eax
c0102c53:	c1 e0 02             	shl    $0x2,%eax
c0102c56:	01 d0                	add    %edx,%eax
c0102c58:	c1 e0 02             	shl    $0x2,%eax
c0102c5b:	89 c2                	mov    %eax,%edx
c0102c5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c60:	01 d0                	add    %edx,%eax
c0102c62:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102c65:	77 9c                	ja     c0102c03 <default_free_pages+0xbc>
      list_add_before(le, &(p->page_link));
    }
    base->flags = 0;
c0102c67:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c6a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    set_page_ref(base, 0);
c0102c71:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102c78:	00 
c0102c79:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c7c:	89 04 24             	mov    %eax,(%esp)
c0102c7f:	e8 bd fb ff ff       	call   c0102841 <set_page_ref>
    ClearPageProperty(base);
c0102c84:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c87:	83 c0 04             	add    $0x4,%eax
c0102c8a:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0102c91:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102c94:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102c97:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102c9a:	0f b3 10             	btr    %edx,(%eax)
    SetPageProperty(base);
c0102c9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ca0:	83 c0 04             	add    $0x4,%eax
c0102ca3:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0102caa:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102cad:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102cb0:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102cb3:	0f ab 10             	bts    %edx,(%eax)
    base->property = n;
c0102cb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cb9:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102cbc:	89 50 08             	mov    %edx,0x8(%eax)
    
    p = le2page(le,page_link) ;
c0102cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102cc2:	83 e8 0c             	sub    $0xc,%eax
c0102cc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if( base+n == p ){
c0102cc8:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102ccb:	89 d0                	mov    %edx,%eax
c0102ccd:	c1 e0 02             	shl    $0x2,%eax
c0102cd0:	01 d0                	add    %edx,%eax
c0102cd2:	c1 e0 02             	shl    $0x2,%eax
c0102cd5:	89 c2                	mov    %eax,%edx
c0102cd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cda:	01 d0                	add    %edx,%eax
c0102cdc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102cdf:	75 1e                	jne    c0102cff <default_free_pages+0x1b8>
      base->property += p->property;
c0102ce1:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ce4:	8b 50 08             	mov    0x8(%eax),%edx
c0102ce7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102cea:	8b 40 08             	mov    0x8(%eax),%eax
c0102ced:	01 c2                	add    %eax,%edx
c0102cef:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cf2:	89 50 08             	mov    %edx,0x8(%eax)
      p->property = 0;
c0102cf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102cf8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
    le = list_prev(&(base->page_link));
c0102cff:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d02:	83 c0 0c             	add    $0xc,%eax
c0102d05:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c0102d08:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102d0b:	8b 00                	mov    (%eax),%eax
c0102d0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = le2page(le, page_link);
c0102d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d13:	83 e8 0c             	sub    $0xc,%eax
c0102d16:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(le!=&free_list && p==base-1){
c0102d19:	81 7d f4 50 89 11 c0 	cmpl   $0xc0118950,-0xc(%ebp)
c0102d20:	74 57                	je     c0102d79 <default_free_pages+0x232>
c0102d22:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d25:	83 e8 14             	sub    $0x14,%eax
c0102d28:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102d2b:	75 4c                	jne    c0102d79 <default_free_pages+0x232>
      while(le!=&free_list){
c0102d2d:	eb 41                	jmp    c0102d70 <default_free_pages+0x229>
        if(p->property){
c0102d2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d32:	8b 40 08             	mov    0x8(%eax),%eax
c0102d35:	85 c0                	test   %eax,%eax
c0102d37:	74 20                	je     c0102d59 <default_free_pages+0x212>
          p->property += base->property;
c0102d39:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d3c:	8b 50 08             	mov    0x8(%eax),%edx
c0102d3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d42:	8b 40 08             	mov    0x8(%eax),%eax
c0102d45:	01 c2                	add    %eax,%edx
c0102d47:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d4a:	89 50 08             	mov    %edx,0x8(%eax)
          base->property = 0;
c0102d4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d50:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
          break;
c0102d57:	eb 20                	jmp    c0102d79 <default_free_pages+0x232>
c0102d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d5c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0102d5f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102d62:	8b 00                	mov    (%eax),%eax
        }
        le = list_prev(le);
c0102d64:	89 45 f4             	mov    %eax,-0xc(%ebp)
        p = le2page(le,page_link);
c0102d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d6a:	83 e8 0c             	sub    $0xc,%eax
c0102d6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      p->property = 0;
    }
    le = list_prev(&(base->page_link));
    p = le2page(le, page_link);
    if(le!=&free_list && p==base-1){
      while(le!=&free_list){
c0102d70:	81 7d f4 50 89 11 c0 	cmpl   $0xc0118950,-0xc(%ebp)
c0102d77:	75 b6                	jne    c0102d2f <default_free_pages+0x1e8>
        le = list_prev(le);
        p = le2page(le,page_link);
      }
    }

    nr_free += n;
c0102d79:	8b 15 58 89 11 c0    	mov    0xc0118958,%edx
c0102d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102d82:	01 d0                	add    %edx,%eax
c0102d84:	a3 58 89 11 c0       	mov    %eax,0xc0118958
    return ;
c0102d89:	90                   	nop
}
c0102d8a:	c9                   	leave  
c0102d8b:	c3                   	ret    

c0102d8c <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0102d8c:	55                   	push   %ebp
c0102d8d:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0102d8f:	a1 58 89 11 c0       	mov    0xc0118958,%eax
}
c0102d94:	5d                   	pop    %ebp
c0102d95:	c3                   	ret    

c0102d96 <basic_check>:

static void
basic_check(void) {
c0102d96:	55                   	push   %ebp
c0102d97:	89 e5                	mov    %esp,%ebp
c0102d99:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0102d9c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102da6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102da9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102dac:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0102daf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102db6:	e8 85 0e 00 00       	call   c0103c40 <alloc_pages>
c0102dbb:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0102dbe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0102dc2:	75 24                	jne    c0102de8 <basic_check+0x52>
c0102dc4:	c7 44 24 0c 24 66 10 	movl   $0xc0106624,0xc(%esp)
c0102dcb:	c0 
c0102dcc:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102dd3:	c0 
c0102dd4:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
c0102ddb:	00 
c0102ddc:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102de3:	e8 de de ff ff       	call   c0100cc6 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0102de8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102def:	e8 4c 0e 00 00       	call   c0103c40 <alloc_pages>
c0102df4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102df7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102dfb:	75 24                	jne    c0102e21 <basic_check+0x8b>
c0102dfd:	c7 44 24 0c 40 66 10 	movl   $0xc0106640,0xc(%esp)
c0102e04:	c0 
c0102e05:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102e0c:	c0 
c0102e0d:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
c0102e14:	00 
c0102e15:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102e1c:	e8 a5 de ff ff       	call   c0100cc6 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0102e21:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102e28:	e8 13 0e 00 00       	call   c0103c40 <alloc_pages>
c0102e2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102e30:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102e34:	75 24                	jne    c0102e5a <basic_check+0xc4>
c0102e36:	c7 44 24 0c 5c 66 10 	movl   $0xc010665c,0xc(%esp)
c0102e3d:	c0 
c0102e3e:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102e45:	c0 
c0102e46:	c7 44 24 04 af 00 00 	movl   $0xaf,0x4(%esp)
c0102e4d:	00 
c0102e4e:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102e55:	e8 6c de ff ff       	call   c0100cc6 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0102e5a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102e5d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102e60:	74 10                	je     c0102e72 <basic_check+0xdc>
c0102e62:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102e65:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102e68:	74 08                	je     c0102e72 <basic_check+0xdc>
c0102e6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e6d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102e70:	75 24                	jne    c0102e96 <basic_check+0x100>
c0102e72:	c7 44 24 0c 78 66 10 	movl   $0xc0106678,0xc(%esp)
c0102e79:	c0 
c0102e7a:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102e81:	c0 
c0102e82:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
c0102e89:	00 
c0102e8a:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102e91:	e8 30 de ff ff       	call   c0100cc6 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0102e96:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102e99:	89 04 24             	mov    %eax,(%esp)
c0102e9c:	e8 96 f9 ff ff       	call   c0102837 <page_ref>
c0102ea1:	85 c0                	test   %eax,%eax
c0102ea3:	75 1e                	jne    c0102ec3 <basic_check+0x12d>
c0102ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ea8:	89 04 24             	mov    %eax,(%esp)
c0102eab:	e8 87 f9 ff ff       	call   c0102837 <page_ref>
c0102eb0:	85 c0                	test   %eax,%eax
c0102eb2:	75 0f                	jne    c0102ec3 <basic_check+0x12d>
c0102eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102eb7:	89 04 24             	mov    %eax,(%esp)
c0102eba:	e8 78 f9 ff ff       	call   c0102837 <page_ref>
c0102ebf:	85 c0                	test   %eax,%eax
c0102ec1:	74 24                	je     c0102ee7 <basic_check+0x151>
c0102ec3:	c7 44 24 0c 9c 66 10 	movl   $0xc010669c,0xc(%esp)
c0102eca:	c0 
c0102ecb:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102ed2:	c0 
c0102ed3:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
c0102eda:	00 
c0102edb:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102ee2:	e8 df dd ff ff       	call   c0100cc6 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0102ee7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102eea:	89 04 24             	mov    %eax,(%esp)
c0102eed:	e8 2f f9 ff ff       	call   c0102821 <page2pa>
c0102ef2:	8b 15 c0 88 11 c0    	mov    0xc01188c0,%edx
c0102ef8:	c1 e2 0c             	shl    $0xc,%edx
c0102efb:	39 d0                	cmp    %edx,%eax
c0102efd:	72 24                	jb     c0102f23 <basic_check+0x18d>
c0102eff:	c7 44 24 0c d8 66 10 	movl   $0xc01066d8,0xc(%esp)
c0102f06:	c0 
c0102f07:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102f0e:	c0 
c0102f0f:	c7 44 24 04 b4 00 00 	movl   $0xb4,0x4(%esp)
c0102f16:	00 
c0102f17:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102f1e:	e8 a3 dd ff ff       	call   c0100cc6 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0102f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102f26:	89 04 24             	mov    %eax,(%esp)
c0102f29:	e8 f3 f8 ff ff       	call   c0102821 <page2pa>
c0102f2e:	8b 15 c0 88 11 c0    	mov    0xc01188c0,%edx
c0102f34:	c1 e2 0c             	shl    $0xc,%edx
c0102f37:	39 d0                	cmp    %edx,%eax
c0102f39:	72 24                	jb     c0102f5f <basic_check+0x1c9>
c0102f3b:	c7 44 24 0c f5 66 10 	movl   $0xc01066f5,0xc(%esp)
c0102f42:	c0 
c0102f43:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102f4a:	c0 
c0102f4b:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c0102f52:	00 
c0102f53:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102f5a:	e8 67 dd ff ff       	call   c0100cc6 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0102f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f62:	89 04 24             	mov    %eax,(%esp)
c0102f65:	e8 b7 f8 ff ff       	call   c0102821 <page2pa>
c0102f6a:	8b 15 c0 88 11 c0    	mov    0xc01188c0,%edx
c0102f70:	c1 e2 0c             	shl    $0xc,%edx
c0102f73:	39 d0                	cmp    %edx,%eax
c0102f75:	72 24                	jb     c0102f9b <basic_check+0x205>
c0102f77:	c7 44 24 0c 12 67 10 	movl   $0xc0106712,0xc(%esp)
c0102f7e:	c0 
c0102f7f:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102f86:	c0 
c0102f87:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c0102f8e:	00 
c0102f8f:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102f96:	e8 2b dd ff ff       	call   c0100cc6 <__panic>

    list_entry_t free_list_store = free_list;
c0102f9b:	a1 50 89 11 c0       	mov    0xc0118950,%eax
c0102fa0:	8b 15 54 89 11 c0    	mov    0xc0118954,%edx
c0102fa6:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102fa9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102fac:	c7 45 e0 50 89 11 c0 	movl   $0xc0118950,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0102fb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102fb6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102fb9:	89 50 04             	mov    %edx,0x4(%eax)
c0102fbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102fbf:	8b 50 04             	mov    0x4(%eax),%edx
c0102fc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102fc5:	89 10                	mov    %edx,(%eax)
c0102fc7:	c7 45 dc 50 89 11 c0 	movl   $0xc0118950,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0102fce:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102fd1:	8b 40 04             	mov    0x4(%eax),%eax
c0102fd4:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0102fd7:	0f 94 c0             	sete   %al
c0102fda:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0102fdd:	85 c0                	test   %eax,%eax
c0102fdf:	75 24                	jne    c0103005 <basic_check+0x26f>
c0102fe1:	c7 44 24 0c 2f 67 10 	movl   $0xc010672f,0xc(%esp)
c0102fe8:	c0 
c0102fe9:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102ff0:	c0 
c0102ff1:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c0102ff8:	00 
c0102ff9:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103000:	e8 c1 dc ff ff       	call   c0100cc6 <__panic>

    unsigned int nr_free_store = nr_free;
c0103005:	a1 58 89 11 c0       	mov    0xc0118958,%eax
c010300a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c010300d:	c7 05 58 89 11 c0 00 	movl   $0x0,0xc0118958
c0103014:	00 00 00 

    assert(alloc_page() == NULL);
c0103017:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010301e:	e8 1d 0c 00 00       	call   c0103c40 <alloc_pages>
c0103023:	85 c0                	test   %eax,%eax
c0103025:	74 24                	je     c010304b <basic_check+0x2b5>
c0103027:	c7 44 24 0c 46 67 10 	movl   $0xc0106746,0xc(%esp)
c010302e:	c0 
c010302f:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103036:	c0 
c0103037:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c010303e:	00 
c010303f:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103046:	e8 7b dc ff ff       	call   c0100cc6 <__panic>

    free_page(p0);
c010304b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103052:	00 
c0103053:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103056:	89 04 24             	mov    %eax,(%esp)
c0103059:	e8 1a 0c 00 00       	call   c0103c78 <free_pages>
    free_page(p1);
c010305e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103065:	00 
c0103066:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103069:	89 04 24             	mov    %eax,(%esp)
c010306c:	e8 07 0c 00 00       	call   c0103c78 <free_pages>
    free_page(p2);
c0103071:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103078:	00 
c0103079:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010307c:	89 04 24             	mov    %eax,(%esp)
c010307f:	e8 f4 0b 00 00       	call   c0103c78 <free_pages>
    assert(nr_free == 3);
c0103084:	a1 58 89 11 c0       	mov    0xc0118958,%eax
c0103089:	83 f8 03             	cmp    $0x3,%eax
c010308c:	74 24                	je     c01030b2 <basic_check+0x31c>
c010308e:	c7 44 24 0c 5b 67 10 	movl   $0xc010675b,0xc(%esp)
c0103095:	c0 
c0103096:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010309d:	c0 
c010309e:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c01030a5:	00 
c01030a6:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01030ad:	e8 14 dc ff ff       	call   c0100cc6 <__panic>

    assert((p0 = alloc_page()) != NULL);
c01030b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01030b9:	e8 82 0b 00 00       	call   c0103c40 <alloc_pages>
c01030be:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01030c1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01030c5:	75 24                	jne    c01030eb <basic_check+0x355>
c01030c7:	c7 44 24 0c 24 66 10 	movl   $0xc0106624,0xc(%esp)
c01030ce:	c0 
c01030cf:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01030d6:	c0 
c01030d7:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c01030de:	00 
c01030df:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01030e6:	e8 db db ff ff       	call   c0100cc6 <__panic>
    assert((p1 = alloc_page()) != NULL);
c01030eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01030f2:	e8 49 0b 00 00       	call   c0103c40 <alloc_pages>
c01030f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01030fa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01030fe:	75 24                	jne    c0103124 <basic_check+0x38e>
c0103100:	c7 44 24 0c 40 66 10 	movl   $0xc0106640,0xc(%esp)
c0103107:	c0 
c0103108:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010310f:	c0 
c0103110:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0103117:	00 
c0103118:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010311f:	e8 a2 db ff ff       	call   c0100cc6 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103124:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010312b:	e8 10 0b 00 00       	call   c0103c40 <alloc_pages>
c0103130:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103133:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103137:	75 24                	jne    c010315d <basic_check+0x3c7>
c0103139:	c7 44 24 0c 5c 66 10 	movl   $0xc010665c,0xc(%esp)
c0103140:	c0 
c0103141:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103148:	c0 
c0103149:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c0103150:	00 
c0103151:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103158:	e8 69 db ff ff       	call   c0100cc6 <__panic>

    assert(alloc_page() == NULL);
c010315d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103164:	e8 d7 0a 00 00       	call   c0103c40 <alloc_pages>
c0103169:	85 c0                	test   %eax,%eax
c010316b:	74 24                	je     c0103191 <basic_check+0x3fb>
c010316d:	c7 44 24 0c 46 67 10 	movl   $0xc0106746,0xc(%esp)
c0103174:	c0 
c0103175:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010317c:	c0 
c010317d:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0103184:	00 
c0103185:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010318c:	e8 35 db ff ff       	call   c0100cc6 <__panic>

    free_page(p0);
c0103191:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103198:	00 
c0103199:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010319c:	89 04 24             	mov    %eax,(%esp)
c010319f:	e8 d4 0a 00 00       	call   c0103c78 <free_pages>
c01031a4:	c7 45 d8 50 89 11 c0 	movl   $0xc0118950,-0x28(%ebp)
c01031ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01031ae:	8b 40 04             	mov    0x4(%eax),%eax
c01031b1:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c01031b4:	0f 94 c0             	sete   %al
c01031b7:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c01031ba:	85 c0                	test   %eax,%eax
c01031bc:	74 24                	je     c01031e2 <basic_check+0x44c>
c01031be:	c7 44 24 0c 68 67 10 	movl   $0xc0106768,0xc(%esp)
c01031c5:	c0 
c01031c6:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01031cd:	c0 
c01031ce:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c01031d5:	00 
c01031d6:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01031dd:	e8 e4 da ff ff       	call   c0100cc6 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c01031e2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01031e9:	e8 52 0a 00 00       	call   c0103c40 <alloc_pages>
c01031ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01031f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01031f4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01031f7:	74 24                	je     c010321d <basic_check+0x487>
c01031f9:	c7 44 24 0c 80 67 10 	movl   $0xc0106780,0xc(%esp)
c0103200:	c0 
c0103201:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103208:	c0 
c0103209:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0103210:	00 
c0103211:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103218:	e8 a9 da ff ff       	call   c0100cc6 <__panic>
    assert(alloc_page() == NULL);
c010321d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103224:	e8 17 0a 00 00       	call   c0103c40 <alloc_pages>
c0103229:	85 c0                	test   %eax,%eax
c010322b:	74 24                	je     c0103251 <basic_check+0x4bb>
c010322d:	c7 44 24 0c 46 67 10 	movl   $0xc0106746,0xc(%esp)
c0103234:	c0 
c0103235:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010323c:	c0 
c010323d:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0103244:	00 
c0103245:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010324c:	e8 75 da ff ff       	call   c0100cc6 <__panic>

    assert(nr_free == 0);
c0103251:	a1 58 89 11 c0       	mov    0xc0118958,%eax
c0103256:	85 c0                	test   %eax,%eax
c0103258:	74 24                	je     c010327e <basic_check+0x4e8>
c010325a:	c7 44 24 0c 99 67 10 	movl   $0xc0106799,0xc(%esp)
c0103261:	c0 
c0103262:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103269:	c0 
c010326a:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0103271:	00 
c0103272:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103279:	e8 48 da ff ff       	call   c0100cc6 <__panic>
    free_list = free_list_store;
c010327e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103281:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103284:	a3 50 89 11 c0       	mov    %eax,0xc0118950
c0103289:	89 15 54 89 11 c0    	mov    %edx,0xc0118954
    nr_free = nr_free_store;
c010328f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103292:	a3 58 89 11 c0       	mov    %eax,0xc0118958

    free_page(p);
c0103297:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010329e:	00 
c010329f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01032a2:	89 04 24             	mov    %eax,(%esp)
c01032a5:	e8 ce 09 00 00       	call   c0103c78 <free_pages>
    free_page(p1);
c01032aa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01032b1:	00 
c01032b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01032b5:	89 04 24             	mov    %eax,(%esp)
c01032b8:	e8 bb 09 00 00       	call   c0103c78 <free_pages>
    free_page(p2);
c01032bd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01032c4:	00 
c01032c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032c8:	89 04 24             	mov    %eax,(%esp)
c01032cb:	e8 a8 09 00 00       	call   c0103c78 <free_pages>
}
c01032d0:	c9                   	leave  
c01032d1:	c3                   	ret    

c01032d2 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c01032d2:	55                   	push   %ebp
c01032d3:	89 e5                	mov    %esp,%ebp
c01032d5:	53                   	push   %ebx
c01032d6:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c01032dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01032e3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c01032ea:	c7 45 ec 50 89 11 c0 	movl   $0xc0118950,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01032f1:	eb 6b                	jmp    c010335e <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c01032f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01032f6:	83 e8 0c             	sub    $0xc,%eax
c01032f9:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c01032fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01032ff:	83 c0 04             	add    $0x4,%eax
c0103302:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103309:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010330c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010330f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103312:	0f a3 10             	bt     %edx,(%eax)
c0103315:	19 c0                	sbb    %eax,%eax
c0103317:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c010331a:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010331e:	0f 95 c0             	setne  %al
c0103321:	0f b6 c0             	movzbl %al,%eax
c0103324:	85 c0                	test   %eax,%eax
c0103326:	75 24                	jne    c010334c <default_check+0x7a>
c0103328:	c7 44 24 0c a6 67 10 	movl   $0xc01067a6,0xc(%esp)
c010332f:	c0 
c0103330:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103337:	c0 
c0103338:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c010333f:	00 
c0103340:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103347:	e8 7a d9 ff ff       	call   c0100cc6 <__panic>
        count ++, total += p->property;
c010334c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103350:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103353:	8b 50 08             	mov    0x8(%eax),%edx
c0103356:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103359:	01 d0                	add    %edx,%eax
c010335b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010335e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103361:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103364:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103367:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c010336a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010336d:	81 7d ec 50 89 11 c0 	cmpl   $0xc0118950,-0x14(%ebp)
c0103374:	0f 85 79 ff ff ff    	jne    c01032f3 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c010337a:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c010337d:	e8 28 09 00 00       	call   c0103caa <nr_free_pages>
c0103382:	39 c3                	cmp    %eax,%ebx
c0103384:	74 24                	je     c01033aa <default_check+0xd8>
c0103386:	c7 44 24 0c b6 67 10 	movl   $0xc01067b6,0xc(%esp)
c010338d:	c0 
c010338e:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103395:	c0 
c0103396:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c010339d:	00 
c010339e:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01033a5:	e8 1c d9 ff ff       	call   c0100cc6 <__panic>

    basic_check();
c01033aa:	e8 e7 f9 ff ff       	call   c0102d96 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c01033af:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01033b6:	e8 85 08 00 00       	call   c0103c40 <alloc_pages>
c01033bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c01033be:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01033c2:	75 24                	jne    c01033e8 <default_check+0x116>
c01033c4:	c7 44 24 0c cf 67 10 	movl   $0xc01067cf,0xc(%esp)
c01033cb:	c0 
c01033cc:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01033d3:	c0 
c01033d4:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c01033db:	00 
c01033dc:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01033e3:	e8 de d8 ff ff       	call   c0100cc6 <__panic>
    assert(!PageProperty(p0));
c01033e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01033eb:	83 c0 04             	add    $0x4,%eax
c01033ee:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01033f5:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01033f8:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01033fb:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01033fe:	0f a3 10             	bt     %edx,(%eax)
c0103401:	19 c0                	sbb    %eax,%eax
c0103403:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0103406:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c010340a:	0f 95 c0             	setne  %al
c010340d:	0f b6 c0             	movzbl %al,%eax
c0103410:	85 c0                	test   %eax,%eax
c0103412:	74 24                	je     c0103438 <default_check+0x166>
c0103414:	c7 44 24 0c da 67 10 	movl   $0xc01067da,0xc(%esp)
c010341b:	c0 
c010341c:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103423:	c0 
c0103424:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c010342b:	00 
c010342c:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103433:	e8 8e d8 ff ff       	call   c0100cc6 <__panic>

    list_entry_t free_list_store = free_list;
c0103438:	a1 50 89 11 c0       	mov    0xc0118950,%eax
c010343d:	8b 15 54 89 11 c0    	mov    0xc0118954,%edx
c0103443:	89 45 80             	mov    %eax,-0x80(%ebp)
c0103446:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0103449:	c7 45 b4 50 89 11 c0 	movl   $0xc0118950,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103450:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103453:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103456:	89 50 04             	mov    %edx,0x4(%eax)
c0103459:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010345c:	8b 50 04             	mov    0x4(%eax),%edx
c010345f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103462:	89 10                	mov    %edx,(%eax)
c0103464:	c7 45 b0 50 89 11 c0 	movl   $0xc0118950,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c010346b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010346e:	8b 40 04             	mov    0x4(%eax),%eax
c0103471:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c0103474:	0f 94 c0             	sete   %al
c0103477:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010347a:	85 c0                	test   %eax,%eax
c010347c:	75 24                	jne    c01034a2 <default_check+0x1d0>
c010347e:	c7 44 24 0c 2f 67 10 	movl   $0xc010672f,0xc(%esp)
c0103485:	c0 
c0103486:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010348d:	c0 
c010348e:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0103495:	00 
c0103496:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010349d:	e8 24 d8 ff ff       	call   c0100cc6 <__panic>
    assert(alloc_page() == NULL);
c01034a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01034a9:	e8 92 07 00 00       	call   c0103c40 <alloc_pages>
c01034ae:	85 c0                	test   %eax,%eax
c01034b0:	74 24                	je     c01034d6 <default_check+0x204>
c01034b2:	c7 44 24 0c 46 67 10 	movl   $0xc0106746,0xc(%esp)
c01034b9:	c0 
c01034ba:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01034c1:	c0 
c01034c2:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c01034c9:	00 
c01034ca:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01034d1:	e8 f0 d7 ff ff       	call   c0100cc6 <__panic>

    unsigned int nr_free_store = nr_free;
c01034d6:	a1 58 89 11 c0       	mov    0xc0118958,%eax
c01034db:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c01034de:	c7 05 58 89 11 c0 00 	movl   $0x0,0xc0118958
c01034e5:	00 00 00 

    free_pages(p0 + 2, 3);
c01034e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01034eb:	83 c0 28             	add    $0x28,%eax
c01034ee:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01034f5:	00 
c01034f6:	89 04 24             	mov    %eax,(%esp)
c01034f9:	e8 7a 07 00 00       	call   c0103c78 <free_pages>
    assert(alloc_pages(4) == NULL);
c01034fe:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0103505:	e8 36 07 00 00       	call   c0103c40 <alloc_pages>
c010350a:	85 c0                	test   %eax,%eax
c010350c:	74 24                	je     c0103532 <default_check+0x260>
c010350e:	c7 44 24 0c ec 67 10 	movl   $0xc01067ec,0xc(%esp)
c0103515:	c0 
c0103516:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010351d:	c0 
c010351e:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0103525:	00 
c0103526:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010352d:	e8 94 d7 ff ff       	call   c0100cc6 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0103532:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103535:	83 c0 28             	add    $0x28,%eax
c0103538:	83 c0 04             	add    $0x4,%eax
c010353b:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0103542:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103545:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103548:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010354b:	0f a3 10             	bt     %edx,(%eax)
c010354e:	19 c0                	sbb    %eax,%eax
c0103550:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0103553:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0103557:	0f 95 c0             	setne  %al
c010355a:	0f b6 c0             	movzbl %al,%eax
c010355d:	85 c0                	test   %eax,%eax
c010355f:	74 0e                	je     c010356f <default_check+0x29d>
c0103561:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103564:	83 c0 28             	add    $0x28,%eax
c0103567:	8b 40 08             	mov    0x8(%eax),%eax
c010356a:	83 f8 03             	cmp    $0x3,%eax
c010356d:	74 24                	je     c0103593 <default_check+0x2c1>
c010356f:	c7 44 24 0c 04 68 10 	movl   $0xc0106804,0xc(%esp)
c0103576:	c0 
c0103577:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010357e:	c0 
c010357f:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0103586:	00 
c0103587:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010358e:	e8 33 d7 ff ff       	call   c0100cc6 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0103593:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c010359a:	e8 a1 06 00 00       	call   c0103c40 <alloc_pages>
c010359f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01035a2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01035a6:	75 24                	jne    c01035cc <default_check+0x2fa>
c01035a8:	c7 44 24 0c 30 68 10 	movl   $0xc0106830,0xc(%esp)
c01035af:	c0 
c01035b0:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01035b7:	c0 
c01035b8:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c01035bf:	00 
c01035c0:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01035c7:	e8 fa d6 ff ff       	call   c0100cc6 <__panic>
    assert(alloc_page() == NULL);
c01035cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01035d3:	e8 68 06 00 00       	call   c0103c40 <alloc_pages>
c01035d8:	85 c0                	test   %eax,%eax
c01035da:	74 24                	je     c0103600 <default_check+0x32e>
c01035dc:	c7 44 24 0c 46 67 10 	movl   $0xc0106746,0xc(%esp)
c01035e3:	c0 
c01035e4:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01035eb:	c0 
c01035ec:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c01035f3:	00 
c01035f4:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01035fb:	e8 c6 d6 ff ff       	call   c0100cc6 <__panic>
    assert(p0 + 2 == p1);
c0103600:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103603:	83 c0 28             	add    $0x28,%eax
c0103606:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0103609:	74 24                	je     c010362f <default_check+0x35d>
c010360b:	c7 44 24 0c 4e 68 10 	movl   $0xc010684e,0xc(%esp)
c0103612:	c0 
c0103613:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010361a:	c0 
c010361b:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0103622:	00 
c0103623:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010362a:	e8 97 d6 ff ff       	call   c0100cc6 <__panic>

    p2 = p0 + 1;
c010362f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103632:	83 c0 14             	add    $0x14,%eax
c0103635:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c0103638:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010363f:	00 
c0103640:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103643:	89 04 24             	mov    %eax,(%esp)
c0103646:	e8 2d 06 00 00       	call   c0103c78 <free_pages>
    free_pages(p1, 3);
c010364b:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0103652:	00 
c0103653:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103656:	89 04 24             	mov    %eax,(%esp)
c0103659:	e8 1a 06 00 00       	call   c0103c78 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010365e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103661:	83 c0 04             	add    $0x4,%eax
c0103664:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c010366b:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010366e:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103671:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0103674:	0f a3 10             	bt     %edx,(%eax)
c0103677:	19 c0                	sbb    %eax,%eax
c0103679:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c010367c:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0103680:	0f 95 c0             	setne  %al
c0103683:	0f b6 c0             	movzbl %al,%eax
c0103686:	85 c0                	test   %eax,%eax
c0103688:	74 0b                	je     c0103695 <default_check+0x3c3>
c010368a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010368d:	8b 40 08             	mov    0x8(%eax),%eax
c0103690:	83 f8 01             	cmp    $0x1,%eax
c0103693:	74 24                	je     c01036b9 <default_check+0x3e7>
c0103695:	c7 44 24 0c 5c 68 10 	movl   $0xc010685c,0xc(%esp)
c010369c:	c0 
c010369d:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01036a4:	c0 
c01036a5:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c01036ac:	00 
c01036ad:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01036b4:	e8 0d d6 ff ff       	call   c0100cc6 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01036b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01036bc:	83 c0 04             	add    $0x4,%eax
c01036bf:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c01036c6:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01036c9:	8b 45 90             	mov    -0x70(%ebp),%eax
c01036cc:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01036cf:	0f a3 10             	bt     %edx,(%eax)
c01036d2:	19 c0                	sbb    %eax,%eax
c01036d4:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01036d7:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01036db:	0f 95 c0             	setne  %al
c01036de:	0f b6 c0             	movzbl %al,%eax
c01036e1:	85 c0                	test   %eax,%eax
c01036e3:	74 0b                	je     c01036f0 <default_check+0x41e>
c01036e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01036e8:	8b 40 08             	mov    0x8(%eax),%eax
c01036eb:	83 f8 03             	cmp    $0x3,%eax
c01036ee:	74 24                	je     c0103714 <default_check+0x442>
c01036f0:	c7 44 24 0c 84 68 10 	movl   $0xc0106884,0xc(%esp)
c01036f7:	c0 
c01036f8:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01036ff:	c0 
c0103700:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c0103707:	00 
c0103708:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010370f:	e8 b2 d5 ff ff       	call   c0100cc6 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0103714:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010371b:	e8 20 05 00 00       	call   c0103c40 <alloc_pages>
c0103720:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103723:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103726:	83 e8 14             	sub    $0x14,%eax
c0103729:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010372c:	74 24                	je     c0103752 <default_check+0x480>
c010372e:	c7 44 24 0c aa 68 10 	movl   $0xc01068aa,0xc(%esp)
c0103735:	c0 
c0103736:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010373d:	c0 
c010373e:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c0103745:	00 
c0103746:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010374d:	e8 74 d5 ff ff       	call   c0100cc6 <__panic>
    free_page(p0);
c0103752:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103759:	00 
c010375a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010375d:	89 04 24             	mov    %eax,(%esp)
c0103760:	e8 13 05 00 00       	call   c0103c78 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0103765:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c010376c:	e8 cf 04 00 00       	call   c0103c40 <alloc_pages>
c0103771:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103774:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103777:	83 c0 14             	add    $0x14,%eax
c010377a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010377d:	74 24                	je     c01037a3 <default_check+0x4d1>
c010377f:	c7 44 24 0c c8 68 10 	movl   $0xc01068c8,0xc(%esp)
c0103786:	c0 
c0103787:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010378e:	c0 
c010378f:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c0103796:	00 
c0103797:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010379e:	e8 23 d5 ff ff       	call   c0100cc6 <__panic>

    free_pages(p0, 2);
c01037a3:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01037aa:	00 
c01037ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037ae:	89 04 24             	mov    %eax,(%esp)
c01037b1:	e8 c2 04 00 00       	call   c0103c78 <free_pages>
    free_page(p2);
c01037b6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01037bd:	00 
c01037be:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01037c1:	89 04 24             	mov    %eax,(%esp)
c01037c4:	e8 af 04 00 00       	call   c0103c78 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01037c9:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01037d0:	e8 6b 04 00 00       	call   c0103c40 <alloc_pages>
c01037d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01037d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01037dc:	75 24                	jne    c0103802 <default_check+0x530>
c01037de:	c7 44 24 0c e8 68 10 	movl   $0xc01068e8,0xc(%esp)
c01037e5:	c0 
c01037e6:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01037ed:	c0 
c01037ee:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c01037f5:	00 
c01037f6:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01037fd:	e8 c4 d4 ff ff       	call   c0100cc6 <__panic>
    assert(alloc_page() == NULL);
c0103802:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103809:	e8 32 04 00 00       	call   c0103c40 <alloc_pages>
c010380e:	85 c0                	test   %eax,%eax
c0103810:	74 24                	je     c0103836 <default_check+0x564>
c0103812:	c7 44 24 0c 46 67 10 	movl   $0xc0106746,0xc(%esp)
c0103819:	c0 
c010381a:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103821:	c0 
c0103822:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0103829:	00 
c010382a:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103831:	e8 90 d4 ff ff       	call   c0100cc6 <__panic>

    assert(nr_free == 0);
c0103836:	a1 58 89 11 c0       	mov    0xc0118958,%eax
c010383b:	85 c0                	test   %eax,%eax
c010383d:	74 24                	je     c0103863 <default_check+0x591>
c010383f:	c7 44 24 0c 99 67 10 	movl   $0xc0106799,0xc(%esp)
c0103846:	c0 
c0103847:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010384e:	c0 
c010384f:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0103856:	00 
c0103857:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010385e:	e8 63 d4 ff ff       	call   c0100cc6 <__panic>
    nr_free = nr_free_store;
c0103863:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103866:	a3 58 89 11 c0       	mov    %eax,0xc0118958

    free_list = free_list_store;
c010386b:	8b 45 80             	mov    -0x80(%ebp),%eax
c010386e:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103871:	a3 50 89 11 c0       	mov    %eax,0xc0118950
c0103876:	89 15 54 89 11 c0    	mov    %edx,0xc0118954
    free_pages(p0, 5);
c010387c:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0103883:	00 
c0103884:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103887:	89 04 24             	mov    %eax,(%esp)
c010388a:	e8 e9 03 00 00       	call   c0103c78 <free_pages>

    le = &free_list;
c010388f:	c7 45 ec 50 89 11 c0 	movl   $0xc0118950,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103896:	eb 1d                	jmp    c01038b5 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c0103898:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010389b:	83 e8 0c             	sub    $0xc,%eax
c010389e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c01038a1:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01038a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01038a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01038ab:	8b 40 08             	mov    0x8(%eax),%eax
c01038ae:	29 c2                	sub    %eax,%edx
c01038b0:	89 d0                	mov    %edx,%eax
c01038b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01038b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01038b8:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01038bb:	8b 45 88             	mov    -0x78(%ebp),%eax
c01038be:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01038c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01038c4:	81 7d ec 50 89 11 c0 	cmpl   $0xc0118950,-0x14(%ebp)
c01038cb:	75 cb                	jne    c0103898 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c01038cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01038d1:	74 24                	je     c01038f7 <default_check+0x625>
c01038d3:	c7 44 24 0c 06 69 10 	movl   $0xc0106906,0xc(%esp)
c01038da:	c0 
c01038db:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01038e2:	c0 
c01038e3:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c01038ea:	00 
c01038eb:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01038f2:	e8 cf d3 ff ff       	call   c0100cc6 <__panic>
    assert(total == 0);
c01038f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01038fb:	74 24                	je     c0103921 <default_check+0x64f>
c01038fd:	c7 44 24 0c 11 69 10 	movl   $0xc0106911,0xc(%esp)
c0103904:	c0 
c0103905:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010390c:	c0 
c010390d:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0103914:	00 
c0103915:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010391c:	e8 a5 d3 ff ff       	call   c0100cc6 <__panic>
}
c0103921:	81 c4 94 00 00 00    	add    $0x94,%esp
c0103927:	5b                   	pop    %ebx
c0103928:	5d                   	pop    %ebp
c0103929:	c3                   	ret    

c010392a <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010392a:	55                   	push   %ebp
c010392b:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010392d:	8b 55 08             	mov    0x8(%ebp),%edx
c0103930:	a1 64 89 11 c0       	mov    0xc0118964,%eax
c0103935:	29 c2                	sub    %eax,%edx
c0103937:	89 d0                	mov    %edx,%eax
c0103939:	c1 f8 02             	sar    $0x2,%eax
c010393c:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0103942:	5d                   	pop    %ebp
c0103943:	c3                   	ret    

c0103944 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103944:	55                   	push   %ebp
c0103945:	89 e5                	mov    %esp,%ebp
c0103947:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010394a:	8b 45 08             	mov    0x8(%ebp),%eax
c010394d:	89 04 24             	mov    %eax,(%esp)
c0103950:	e8 d5 ff ff ff       	call   c010392a <page2ppn>
c0103955:	c1 e0 0c             	shl    $0xc,%eax
}
c0103958:	c9                   	leave  
c0103959:	c3                   	ret    

c010395a <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c010395a:	55                   	push   %ebp
c010395b:	89 e5                	mov    %esp,%ebp
c010395d:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103960:	8b 45 08             	mov    0x8(%ebp),%eax
c0103963:	c1 e8 0c             	shr    $0xc,%eax
c0103966:	89 c2                	mov    %eax,%edx
c0103968:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c010396d:	39 c2                	cmp    %eax,%edx
c010396f:	72 1c                	jb     c010398d <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103971:	c7 44 24 08 4c 69 10 	movl   $0xc010694c,0x8(%esp)
c0103978:	c0 
c0103979:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0103980:	00 
c0103981:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103988:	e8 39 d3 ff ff       	call   c0100cc6 <__panic>
    }
    return &pages[PPN(pa)];
c010398d:	8b 0d 64 89 11 c0    	mov    0xc0118964,%ecx
c0103993:	8b 45 08             	mov    0x8(%ebp),%eax
c0103996:	c1 e8 0c             	shr    $0xc,%eax
c0103999:	89 c2                	mov    %eax,%edx
c010399b:	89 d0                	mov    %edx,%eax
c010399d:	c1 e0 02             	shl    $0x2,%eax
c01039a0:	01 d0                	add    %edx,%eax
c01039a2:	c1 e0 02             	shl    $0x2,%eax
c01039a5:	01 c8                	add    %ecx,%eax
}
c01039a7:	c9                   	leave  
c01039a8:	c3                   	ret    

c01039a9 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c01039a9:	55                   	push   %ebp
c01039aa:	89 e5                	mov    %esp,%ebp
c01039ac:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01039af:	8b 45 08             	mov    0x8(%ebp),%eax
c01039b2:	89 04 24             	mov    %eax,(%esp)
c01039b5:	e8 8a ff ff ff       	call   c0103944 <page2pa>
c01039ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01039bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039c0:	c1 e8 0c             	shr    $0xc,%eax
c01039c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01039c6:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c01039cb:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01039ce:	72 23                	jb     c01039f3 <page2kva+0x4a>
c01039d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01039d7:	c7 44 24 08 7c 69 10 	movl   $0xc010697c,0x8(%esp)
c01039de:	c0 
c01039df:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c01039e6:	00 
c01039e7:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c01039ee:	e8 d3 d2 ff ff       	call   c0100cc6 <__panic>
c01039f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039f6:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01039fb:	c9                   	leave  
c01039fc:	c3                   	ret    

c01039fd <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c01039fd:	55                   	push   %ebp
c01039fe:	89 e5                	mov    %esp,%ebp
c0103a00:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0103a03:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a06:	83 e0 01             	and    $0x1,%eax
c0103a09:	85 c0                	test   %eax,%eax
c0103a0b:	75 1c                	jne    c0103a29 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0103a0d:	c7 44 24 08 a0 69 10 	movl   $0xc01069a0,0x8(%esp)
c0103a14:	c0 
c0103a15:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0103a1c:	00 
c0103a1d:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103a24:	e8 9d d2 ff ff       	call   c0100cc6 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0103a29:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a2c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103a31:	89 04 24             	mov    %eax,(%esp)
c0103a34:	e8 21 ff ff ff       	call   c010395a <pa2page>
}
c0103a39:	c9                   	leave  
c0103a3a:	c3                   	ret    

c0103a3b <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0103a3b:	55                   	push   %ebp
c0103a3c:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103a3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a41:	8b 00                	mov    (%eax),%eax
}
c0103a43:	5d                   	pop    %ebp
c0103a44:	c3                   	ret    

c0103a45 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103a45:	55                   	push   %ebp
c0103a46:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103a48:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103a4e:	89 10                	mov    %edx,(%eax)
}
c0103a50:	5d                   	pop    %ebp
c0103a51:	c3                   	ret    

c0103a52 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0103a52:	55                   	push   %ebp
c0103a53:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0103a55:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a58:	8b 00                	mov    (%eax),%eax
c0103a5a:	8d 50 01             	lea    0x1(%eax),%edx
c0103a5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a60:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103a62:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a65:	8b 00                	mov    (%eax),%eax
}
c0103a67:	5d                   	pop    %ebp
c0103a68:	c3                   	ret    

c0103a69 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0103a69:	55                   	push   %ebp
c0103a6a:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0103a6c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a6f:	8b 00                	mov    (%eax),%eax
c0103a71:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103a74:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a77:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103a79:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a7c:	8b 00                	mov    (%eax),%eax
}
c0103a7e:	5d                   	pop    %ebp
c0103a7f:	c3                   	ret    

c0103a80 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0103a80:	55                   	push   %ebp
c0103a81:	89 e5                	mov    %esp,%ebp
c0103a83:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0103a86:	9c                   	pushf  
c0103a87:	58                   	pop    %eax
c0103a88:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0103a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0103a8e:	25 00 02 00 00       	and    $0x200,%eax
c0103a93:	85 c0                	test   %eax,%eax
c0103a95:	74 0c                	je     c0103aa3 <__intr_save+0x23>
        intr_disable();
c0103a97:	e8 0d dc ff ff       	call   c01016a9 <intr_disable>
        return 1;
c0103a9c:	b8 01 00 00 00       	mov    $0x1,%eax
c0103aa1:	eb 05                	jmp    c0103aa8 <__intr_save+0x28>
    }
    return 0;
c0103aa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103aa8:	c9                   	leave  
c0103aa9:	c3                   	ret    

c0103aaa <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0103aaa:	55                   	push   %ebp
c0103aab:	89 e5                	mov    %esp,%ebp
c0103aad:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0103ab0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103ab4:	74 05                	je     c0103abb <__intr_restore+0x11>
        intr_enable();
c0103ab6:	e8 e8 db ff ff       	call   c01016a3 <intr_enable>
    }
}
c0103abb:	c9                   	leave  
c0103abc:	c3                   	ret    

c0103abd <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0103abd:	55                   	push   %ebp
c0103abe:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0103ac0:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ac3:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0103ac6:	b8 23 00 00 00       	mov    $0x23,%eax
c0103acb:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0103acd:	b8 23 00 00 00       	mov    $0x23,%eax
c0103ad2:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0103ad4:	b8 10 00 00 00       	mov    $0x10,%eax
c0103ad9:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0103adb:	b8 10 00 00 00       	mov    $0x10,%eax
c0103ae0:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0103ae2:	b8 10 00 00 00       	mov    $0x10,%eax
c0103ae7:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0103ae9:	ea f0 3a 10 c0 08 00 	ljmp   $0x8,$0xc0103af0
}
c0103af0:	5d                   	pop    %ebp
c0103af1:	c3                   	ret    

c0103af2 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0103af2:	55                   	push   %ebp
c0103af3:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0103af5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103af8:	a3 e4 88 11 c0       	mov    %eax,0xc01188e4
}
c0103afd:	5d                   	pop    %ebp
c0103afe:	c3                   	ret    

c0103aff <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0103aff:	55                   	push   %ebp
c0103b00:	89 e5                	mov    %esp,%ebp
c0103b02:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0103b05:	b8 00 70 11 c0       	mov    $0xc0117000,%eax
c0103b0a:	89 04 24             	mov    %eax,(%esp)
c0103b0d:	e8 e0 ff ff ff       	call   c0103af2 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0103b12:	66 c7 05 e8 88 11 c0 	movw   $0x10,0xc01188e8
c0103b19:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0103b1b:	66 c7 05 28 7a 11 c0 	movw   $0x68,0xc0117a28
c0103b22:	68 00 
c0103b24:	b8 e0 88 11 c0       	mov    $0xc01188e0,%eax
c0103b29:	66 a3 2a 7a 11 c0    	mov    %ax,0xc0117a2a
c0103b2f:	b8 e0 88 11 c0       	mov    $0xc01188e0,%eax
c0103b34:	c1 e8 10             	shr    $0x10,%eax
c0103b37:	a2 2c 7a 11 c0       	mov    %al,0xc0117a2c
c0103b3c:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103b43:	83 e0 f0             	and    $0xfffffff0,%eax
c0103b46:	83 c8 09             	or     $0x9,%eax
c0103b49:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103b4e:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103b55:	83 e0 ef             	and    $0xffffffef,%eax
c0103b58:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103b5d:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103b64:	83 e0 9f             	and    $0xffffff9f,%eax
c0103b67:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103b6c:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103b73:	83 c8 80             	or     $0xffffff80,%eax
c0103b76:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103b7b:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103b82:	83 e0 f0             	and    $0xfffffff0,%eax
c0103b85:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103b8a:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103b91:	83 e0 ef             	and    $0xffffffef,%eax
c0103b94:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103b99:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103ba0:	83 e0 df             	and    $0xffffffdf,%eax
c0103ba3:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103ba8:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103baf:	83 c8 40             	or     $0x40,%eax
c0103bb2:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103bb7:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103bbe:	83 e0 7f             	and    $0x7f,%eax
c0103bc1:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103bc6:	b8 e0 88 11 c0       	mov    $0xc01188e0,%eax
c0103bcb:	c1 e8 18             	shr    $0x18,%eax
c0103bce:	a2 2f 7a 11 c0       	mov    %al,0xc0117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0103bd3:	c7 04 24 30 7a 11 c0 	movl   $0xc0117a30,(%esp)
c0103bda:	e8 de fe ff ff       	call   c0103abd <lgdt>
c0103bdf:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0103be5:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0103be9:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0103bec:	c9                   	leave  
c0103bed:	c3                   	ret    

c0103bee <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0103bee:	55                   	push   %ebp
c0103bef:	89 e5                	mov    %esp,%ebp
c0103bf1:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0103bf4:	c7 05 5c 89 11 c0 30 	movl   $0xc0106930,0xc011895c
c0103bfb:	69 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0103bfe:	a1 5c 89 11 c0       	mov    0xc011895c,%eax
c0103c03:	8b 00                	mov    (%eax),%eax
c0103c05:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c09:	c7 04 24 cc 69 10 c0 	movl   $0xc01069cc,(%esp)
c0103c10:	e8 27 c7 ff ff       	call   c010033c <cprintf>
    pmm_manager->init();
c0103c15:	a1 5c 89 11 c0       	mov    0xc011895c,%eax
c0103c1a:	8b 40 04             	mov    0x4(%eax),%eax
c0103c1d:	ff d0                	call   *%eax
}
c0103c1f:	c9                   	leave  
c0103c20:	c3                   	ret    

c0103c21 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0103c21:	55                   	push   %ebp
c0103c22:	89 e5                	mov    %esp,%ebp
c0103c24:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0103c27:	a1 5c 89 11 c0       	mov    0xc011895c,%eax
c0103c2c:	8b 40 08             	mov    0x8(%eax),%eax
c0103c2f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103c32:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103c36:	8b 55 08             	mov    0x8(%ebp),%edx
c0103c39:	89 14 24             	mov    %edx,(%esp)
c0103c3c:	ff d0                	call   *%eax
}
c0103c3e:	c9                   	leave  
c0103c3f:	c3                   	ret    

c0103c40 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0103c40:	55                   	push   %ebp
c0103c41:	89 e5                	mov    %esp,%ebp
c0103c43:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0103c46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0103c4d:	e8 2e fe ff ff       	call   c0103a80 <__intr_save>
c0103c52:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0103c55:	a1 5c 89 11 c0       	mov    0xc011895c,%eax
c0103c5a:	8b 40 0c             	mov    0xc(%eax),%eax
c0103c5d:	8b 55 08             	mov    0x8(%ebp),%edx
c0103c60:	89 14 24             	mov    %edx,(%esp)
c0103c63:	ff d0                	call   *%eax
c0103c65:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0103c68:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c6b:	89 04 24             	mov    %eax,(%esp)
c0103c6e:	e8 37 fe ff ff       	call   c0103aaa <__intr_restore>
    return page;
c0103c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103c76:	c9                   	leave  
c0103c77:	c3                   	ret    

c0103c78 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0103c78:	55                   	push   %ebp
c0103c79:	89 e5                	mov    %esp,%ebp
c0103c7b:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0103c7e:	e8 fd fd ff ff       	call   c0103a80 <__intr_save>
c0103c83:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0103c86:	a1 5c 89 11 c0       	mov    0xc011895c,%eax
c0103c8b:	8b 40 10             	mov    0x10(%eax),%eax
c0103c8e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103c91:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103c95:	8b 55 08             	mov    0x8(%ebp),%edx
c0103c98:	89 14 24             	mov    %edx,(%esp)
c0103c9b:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0103c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ca0:	89 04 24             	mov    %eax,(%esp)
c0103ca3:	e8 02 fe ff ff       	call   c0103aaa <__intr_restore>
}
c0103ca8:	c9                   	leave  
c0103ca9:	c3                   	ret    

c0103caa <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0103caa:	55                   	push   %ebp
c0103cab:	89 e5                	mov    %esp,%ebp
c0103cad:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0103cb0:	e8 cb fd ff ff       	call   c0103a80 <__intr_save>
c0103cb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0103cb8:	a1 5c 89 11 c0       	mov    0xc011895c,%eax
c0103cbd:	8b 40 14             	mov    0x14(%eax),%eax
c0103cc0:	ff d0                	call   *%eax
c0103cc2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0103cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cc8:	89 04 24             	mov    %eax,(%esp)
c0103ccb:	e8 da fd ff ff       	call   c0103aaa <__intr_restore>
    return ret;
c0103cd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0103cd3:	c9                   	leave  
c0103cd4:	c3                   	ret    

c0103cd5 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0103cd5:	55                   	push   %ebp
c0103cd6:	89 e5                	mov    %esp,%ebp
c0103cd8:	57                   	push   %edi
c0103cd9:	56                   	push   %esi
c0103cda:	53                   	push   %ebx
c0103cdb:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0103ce1:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0103ce8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0103cef:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0103cf6:	c7 04 24 e3 69 10 c0 	movl   $0xc01069e3,(%esp)
c0103cfd:	e8 3a c6 ff ff       	call   c010033c <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103d02:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103d09:	e9 15 01 00 00       	jmp    c0103e23 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103d0e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103d11:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103d14:	89 d0                	mov    %edx,%eax
c0103d16:	c1 e0 02             	shl    $0x2,%eax
c0103d19:	01 d0                	add    %edx,%eax
c0103d1b:	c1 e0 02             	shl    $0x2,%eax
c0103d1e:	01 c8                	add    %ecx,%eax
c0103d20:	8b 50 08             	mov    0x8(%eax),%edx
c0103d23:	8b 40 04             	mov    0x4(%eax),%eax
c0103d26:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103d29:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0103d2c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103d2f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103d32:	89 d0                	mov    %edx,%eax
c0103d34:	c1 e0 02             	shl    $0x2,%eax
c0103d37:	01 d0                	add    %edx,%eax
c0103d39:	c1 e0 02             	shl    $0x2,%eax
c0103d3c:	01 c8                	add    %ecx,%eax
c0103d3e:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103d41:	8b 58 10             	mov    0x10(%eax),%ebx
c0103d44:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103d47:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103d4a:	01 c8                	add    %ecx,%eax
c0103d4c:	11 da                	adc    %ebx,%edx
c0103d4e:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0103d51:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0103d54:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103d57:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103d5a:	89 d0                	mov    %edx,%eax
c0103d5c:	c1 e0 02             	shl    $0x2,%eax
c0103d5f:	01 d0                	add    %edx,%eax
c0103d61:	c1 e0 02             	shl    $0x2,%eax
c0103d64:	01 c8                	add    %ecx,%eax
c0103d66:	83 c0 14             	add    $0x14,%eax
c0103d69:	8b 00                	mov    (%eax),%eax
c0103d6b:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0103d71:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103d74:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103d77:	83 c0 ff             	add    $0xffffffff,%eax
c0103d7a:	83 d2 ff             	adc    $0xffffffff,%edx
c0103d7d:	89 c6                	mov    %eax,%esi
c0103d7f:	89 d7                	mov    %edx,%edi
c0103d81:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103d84:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103d87:	89 d0                	mov    %edx,%eax
c0103d89:	c1 e0 02             	shl    $0x2,%eax
c0103d8c:	01 d0                	add    %edx,%eax
c0103d8e:	c1 e0 02             	shl    $0x2,%eax
c0103d91:	01 c8                	add    %ecx,%eax
c0103d93:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103d96:	8b 58 10             	mov    0x10(%eax),%ebx
c0103d99:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0103d9f:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0103da3:	89 74 24 14          	mov    %esi,0x14(%esp)
c0103da7:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0103dab:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103dae:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103db1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103db5:	89 54 24 10          	mov    %edx,0x10(%esp)
c0103db9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103dbd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0103dc1:	c7 04 24 f0 69 10 c0 	movl   $0xc01069f0,(%esp)
c0103dc8:	e8 6f c5 ff ff       	call   c010033c <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0103dcd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103dd0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103dd3:	89 d0                	mov    %edx,%eax
c0103dd5:	c1 e0 02             	shl    $0x2,%eax
c0103dd8:	01 d0                	add    %edx,%eax
c0103dda:	c1 e0 02             	shl    $0x2,%eax
c0103ddd:	01 c8                	add    %ecx,%eax
c0103ddf:	83 c0 14             	add    $0x14,%eax
c0103de2:	8b 00                	mov    (%eax),%eax
c0103de4:	83 f8 01             	cmp    $0x1,%eax
c0103de7:	75 36                	jne    c0103e1f <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0103de9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103dec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103def:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103df2:	77 2b                	ja     c0103e1f <page_init+0x14a>
c0103df4:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103df7:	72 05                	jb     c0103dfe <page_init+0x129>
c0103df9:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0103dfc:	73 21                	jae    c0103e1f <page_init+0x14a>
c0103dfe:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103e02:	77 1b                	ja     c0103e1f <page_init+0x14a>
c0103e04:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103e08:	72 09                	jb     c0103e13 <page_init+0x13e>
c0103e0a:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0103e11:	77 0c                	ja     c0103e1f <page_init+0x14a>
                maxpa = end;
c0103e13:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103e16:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103e19:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103e1c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103e1f:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0103e23:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103e26:	8b 00                	mov    (%eax),%eax
c0103e28:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0103e2b:	0f 8f dd fe ff ff    	jg     c0103d0e <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0103e31:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103e35:	72 1d                	jb     c0103e54 <page_init+0x17f>
c0103e37:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103e3b:	77 09                	ja     c0103e46 <page_init+0x171>
c0103e3d:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0103e44:	76 0e                	jbe    c0103e54 <page_init+0x17f>
        maxpa = KMEMSIZE;
c0103e46:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0103e4d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0103e54:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103e57:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103e5a:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103e5e:	c1 ea 0c             	shr    $0xc,%edx
c0103e61:	a3 c0 88 11 c0       	mov    %eax,0xc01188c0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0103e66:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0103e6d:	b8 68 89 11 c0       	mov    $0xc0118968,%eax
c0103e72:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103e75:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103e78:	01 d0                	add    %edx,%eax
c0103e7a:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0103e7d:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103e80:	ba 00 00 00 00       	mov    $0x0,%edx
c0103e85:	f7 75 ac             	divl   -0x54(%ebp)
c0103e88:	89 d0                	mov    %edx,%eax
c0103e8a:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103e8d:	29 c2                	sub    %eax,%edx
c0103e8f:	89 d0                	mov    %edx,%eax
c0103e91:	a3 64 89 11 c0       	mov    %eax,0xc0118964

    for (i = 0; i < npage; i ++) {
c0103e96:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103e9d:	eb 2f                	jmp    c0103ece <page_init+0x1f9>
        SetPageReserved(pages + i);
c0103e9f:	8b 0d 64 89 11 c0    	mov    0xc0118964,%ecx
c0103ea5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103ea8:	89 d0                	mov    %edx,%eax
c0103eaa:	c1 e0 02             	shl    $0x2,%eax
c0103ead:	01 d0                	add    %edx,%eax
c0103eaf:	c1 e0 02             	shl    $0x2,%eax
c0103eb2:	01 c8                	add    %ecx,%eax
c0103eb4:	83 c0 04             	add    $0x4,%eax
c0103eb7:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0103ebe:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103ec1:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103ec4:	8b 55 90             	mov    -0x70(%ebp),%edx
c0103ec7:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0103eca:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0103ece:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103ed1:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c0103ed6:	39 c2                	cmp    %eax,%edx
c0103ed8:	72 c5                	jb     c0103e9f <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0103eda:	8b 15 c0 88 11 c0    	mov    0xc01188c0,%edx
c0103ee0:	89 d0                	mov    %edx,%eax
c0103ee2:	c1 e0 02             	shl    $0x2,%eax
c0103ee5:	01 d0                	add    %edx,%eax
c0103ee7:	c1 e0 02             	shl    $0x2,%eax
c0103eea:	89 c2                	mov    %eax,%edx
c0103eec:	a1 64 89 11 c0       	mov    0xc0118964,%eax
c0103ef1:	01 d0                	add    %edx,%eax
c0103ef3:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0103ef6:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0103efd:	77 23                	ja     c0103f22 <page_init+0x24d>
c0103eff:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0103f02:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103f06:	c7 44 24 08 20 6a 10 	movl   $0xc0106a20,0x8(%esp)
c0103f0d:	c0 
c0103f0e:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0103f15:	00 
c0103f16:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0103f1d:	e8 a4 cd ff ff       	call   c0100cc6 <__panic>
c0103f22:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0103f25:	05 00 00 00 40       	add    $0x40000000,%eax
c0103f2a:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0103f2d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103f34:	e9 74 01 00 00       	jmp    c01040ad <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103f39:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103f3c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f3f:	89 d0                	mov    %edx,%eax
c0103f41:	c1 e0 02             	shl    $0x2,%eax
c0103f44:	01 d0                	add    %edx,%eax
c0103f46:	c1 e0 02             	shl    $0x2,%eax
c0103f49:	01 c8                	add    %ecx,%eax
c0103f4b:	8b 50 08             	mov    0x8(%eax),%edx
c0103f4e:	8b 40 04             	mov    0x4(%eax),%eax
c0103f51:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103f54:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103f57:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103f5a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f5d:	89 d0                	mov    %edx,%eax
c0103f5f:	c1 e0 02             	shl    $0x2,%eax
c0103f62:	01 d0                	add    %edx,%eax
c0103f64:	c1 e0 02             	shl    $0x2,%eax
c0103f67:	01 c8                	add    %ecx,%eax
c0103f69:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103f6c:	8b 58 10             	mov    0x10(%eax),%ebx
c0103f6f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103f72:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103f75:	01 c8                	add    %ecx,%eax
c0103f77:	11 da                	adc    %ebx,%edx
c0103f79:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0103f7c:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0103f7f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103f82:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f85:	89 d0                	mov    %edx,%eax
c0103f87:	c1 e0 02             	shl    $0x2,%eax
c0103f8a:	01 d0                	add    %edx,%eax
c0103f8c:	c1 e0 02             	shl    $0x2,%eax
c0103f8f:	01 c8                	add    %ecx,%eax
c0103f91:	83 c0 14             	add    $0x14,%eax
c0103f94:	8b 00                	mov    (%eax),%eax
c0103f96:	83 f8 01             	cmp    $0x1,%eax
c0103f99:	0f 85 0a 01 00 00    	jne    c01040a9 <page_init+0x3d4>
            if (begin < freemem) {
c0103f9f:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103fa2:	ba 00 00 00 00       	mov    $0x0,%edx
c0103fa7:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0103faa:	72 17                	jb     c0103fc3 <page_init+0x2ee>
c0103fac:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0103faf:	77 05                	ja     c0103fb6 <page_init+0x2e1>
c0103fb1:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0103fb4:	76 0d                	jbe    c0103fc3 <page_init+0x2ee>
                begin = freemem;
c0103fb6:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103fb9:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103fbc:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0103fc3:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0103fc7:	72 1d                	jb     c0103fe6 <page_init+0x311>
c0103fc9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0103fcd:	77 09                	ja     c0103fd8 <page_init+0x303>
c0103fcf:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0103fd6:	76 0e                	jbe    c0103fe6 <page_init+0x311>
                end = KMEMSIZE;
c0103fd8:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0103fdf:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0103fe6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103fe9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103fec:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103fef:	0f 87 b4 00 00 00    	ja     c01040a9 <page_init+0x3d4>
c0103ff5:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103ff8:	72 09                	jb     c0104003 <page_init+0x32e>
c0103ffa:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0103ffd:	0f 83 a6 00 00 00    	jae    c01040a9 <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
c0104003:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c010400a:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010400d:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104010:	01 d0                	add    %edx,%eax
c0104012:	83 e8 01             	sub    $0x1,%eax
c0104015:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104018:	8b 45 98             	mov    -0x68(%ebp),%eax
c010401b:	ba 00 00 00 00       	mov    $0x0,%edx
c0104020:	f7 75 9c             	divl   -0x64(%ebp)
c0104023:	89 d0                	mov    %edx,%eax
c0104025:	8b 55 98             	mov    -0x68(%ebp),%edx
c0104028:	29 c2                	sub    %eax,%edx
c010402a:	89 d0                	mov    %edx,%eax
c010402c:	ba 00 00 00 00       	mov    $0x0,%edx
c0104031:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104034:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0104037:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010403a:	89 45 94             	mov    %eax,-0x6c(%ebp)
c010403d:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104040:	ba 00 00 00 00       	mov    $0x0,%edx
c0104045:	89 c7                	mov    %eax,%edi
c0104047:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c010404d:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0104050:	89 d0                	mov    %edx,%eax
c0104052:	83 e0 00             	and    $0x0,%eax
c0104055:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0104058:	8b 45 80             	mov    -0x80(%ebp),%eax
c010405b:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010405e:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104061:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0104064:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104067:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010406a:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010406d:	77 3a                	ja     c01040a9 <page_init+0x3d4>
c010406f:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104072:	72 05                	jb     c0104079 <page_init+0x3a4>
c0104074:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104077:	73 30                	jae    c01040a9 <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0104079:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c010407c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c010407f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104082:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104085:	29 c8                	sub    %ecx,%eax
c0104087:	19 da                	sbb    %ebx,%edx
c0104089:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010408d:	c1 ea 0c             	shr    $0xc,%edx
c0104090:	89 c3                	mov    %eax,%ebx
c0104092:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104095:	89 04 24             	mov    %eax,(%esp)
c0104098:	e8 bd f8 ff ff       	call   c010395a <pa2page>
c010409d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01040a1:	89 04 24             	mov    %eax,(%esp)
c01040a4:	e8 78 fb ff ff       	call   c0103c21 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c01040a9:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01040ad:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01040b0:	8b 00                	mov    (%eax),%eax
c01040b2:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01040b5:	0f 8f 7e fe ff ff    	jg     c0103f39 <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c01040bb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c01040c1:	5b                   	pop    %ebx
c01040c2:	5e                   	pop    %esi
c01040c3:	5f                   	pop    %edi
c01040c4:	5d                   	pop    %ebp
c01040c5:	c3                   	ret    

c01040c6 <enable_paging>:

static void
enable_paging(void) {
c01040c6:	55                   	push   %ebp
c01040c7:	89 e5                	mov    %esp,%ebp
c01040c9:	83 ec 10             	sub    $0x10,%esp
    lcr3(boot_cr3);
c01040cc:	a1 60 89 11 c0       	mov    0xc0118960,%eax
c01040d1:	89 45 f8             	mov    %eax,-0x8(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c01040d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01040d7:	0f 22 d8             	mov    %eax,%cr3
}

static inline uintptr_t
rcr0(void) {
    uintptr_t cr0;
    asm volatile ("mov %%cr0, %0" : "=r" (cr0) :: "memory");
c01040da:	0f 20 c0             	mov    %cr0,%eax
c01040dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr0;
c01040e0:	8b 45 f4             	mov    -0xc(%ebp),%eax

    // turn on paging
    uint32_t cr0 = rcr0();
c01040e3:	89 45 fc             	mov    %eax,-0x4(%ebp)
    cr0 |= CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP;
c01040e6:	81 4d fc 2f 00 05 80 	orl    $0x8005002f,-0x4(%ebp)
    cr0 &= ~(CR0_TS | CR0_EM);
c01040ed:	83 65 fc f3          	andl   $0xfffffff3,-0x4(%ebp)
c01040f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01040f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile ("pushl %0; popfl" :: "r" (eflags));
}

static inline void
lcr0(uintptr_t cr0) {
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
c01040f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01040fa:	0f 22 c0             	mov    %eax,%cr0
    lcr0(cr0);
}
c01040fd:	c9                   	leave  
c01040fe:	c3                   	ret    

c01040ff <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c01040ff:	55                   	push   %ebp
c0104100:	89 e5                	mov    %esp,%ebp
c0104102:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0104105:	8b 45 14             	mov    0x14(%ebp),%eax
c0104108:	8b 55 0c             	mov    0xc(%ebp),%edx
c010410b:	31 d0                	xor    %edx,%eax
c010410d:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104112:	85 c0                	test   %eax,%eax
c0104114:	74 24                	je     c010413a <boot_map_segment+0x3b>
c0104116:	c7 44 24 0c 52 6a 10 	movl   $0xc0106a52,0xc(%esp)
c010411d:	c0 
c010411e:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104125:	c0 
c0104126:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c010412d:	00 
c010412e:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104135:	e8 8c cb ff ff       	call   c0100cc6 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c010413a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0104141:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104144:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104149:	89 c2                	mov    %eax,%edx
c010414b:	8b 45 10             	mov    0x10(%ebp),%eax
c010414e:	01 c2                	add    %eax,%edx
c0104150:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104153:	01 d0                	add    %edx,%eax
c0104155:	83 e8 01             	sub    $0x1,%eax
c0104158:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010415b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010415e:	ba 00 00 00 00       	mov    $0x0,%edx
c0104163:	f7 75 f0             	divl   -0x10(%ebp)
c0104166:	89 d0                	mov    %edx,%eax
c0104168:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010416b:	29 c2                	sub    %eax,%edx
c010416d:	89 d0                	mov    %edx,%eax
c010416f:	c1 e8 0c             	shr    $0xc,%eax
c0104172:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0104175:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104178:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010417b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010417e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104183:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0104186:	8b 45 14             	mov    0x14(%ebp),%eax
c0104189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010418c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010418f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104194:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104197:	eb 6b                	jmp    c0104204 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0104199:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01041a0:	00 
c01041a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01041a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01041a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01041ab:	89 04 24             	mov    %eax,(%esp)
c01041ae:	e8 cc 01 00 00       	call   c010437f <get_pte>
c01041b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01041b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01041ba:	75 24                	jne    c01041e0 <boot_map_segment+0xe1>
c01041bc:	c7 44 24 0c 7e 6a 10 	movl   $0xc0106a7e,0xc(%esp)
c01041c3:	c0 
c01041c4:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c01041cb:	c0 
c01041cc:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c01041d3:	00 
c01041d4:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c01041db:	e8 e6 ca ff ff       	call   c0100cc6 <__panic>
        *ptep = pa | PTE_P | perm;
c01041e0:	8b 45 18             	mov    0x18(%ebp),%eax
c01041e3:	8b 55 14             	mov    0x14(%ebp),%edx
c01041e6:	09 d0                	or     %edx,%eax
c01041e8:	83 c8 01             	or     $0x1,%eax
c01041eb:	89 c2                	mov    %eax,%edx
c01041ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01041f0:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01041f2:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01041f6:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01041fd:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0104204:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104208:	75 8f                	jne    c0104199 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c010420a:	c9                   	leave  
c010420b:	c3                   	ret    

c010420c <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c010420c:	55                   	push   %ebp
c010420d:	89 e5                	mov    %esp,%ebp
c010420f:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0104212:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104219:	e8 22 fa ff ff       	call   c0103c40 <alloc_pages>
c010421e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0104221:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104225:	75 1c                	jne    c0104243 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0104227:	c7 44 24 08 8b 6a 10 	movl   $0xc0106a8b,0x8(%esp)
c010422e:	c0 
c010422f:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c0104236:	00 
c0104237:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c010423e:	e8 83 ca ff ff       	call   c0100cc6 <__panic>
    }
    return page2kva(p);
c0104243:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104246:	89 04 24             	mov    %eax,(%esp)
c0104249:	e8 5b f7 ff ff       	call   c01039a9 <page2kva>
}
c010424e:	c9                   	leave  
c010424f:	c3                   	ret    

c0104250 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0104250:	55                   	push   %ebp
c0104251:	89 e5                	mov    %esp,%ebp
c0104253:	83 ec 38             	sub    $0x38,%esp
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0104256:	e8 93 f9 ff ff       	call   c0103bee <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c010425b:	e8 75 fa ff ff       	call   c0103cd5 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0104260:	e8 66 04 00 00       	call   c01046cb <check_alloc_page>

    // create boot_pgdir, an initial page directory(Page Directory Table, PDT)
    boot_pgdir = boot_alloc_page();
c0104265:	e8 a2 ff ff ff       	call   c010420c <boot_alloc_page>
c010426a:	a3 c4 88 11 c0       	mov    %eax,0xc01188c4
    memset(boot_pgdir, 0, PGSIZE);
c010426f:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104274:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010427b:	00 
c010427c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104283:	00 
c0104284:	89 04 24             	mov    %eax,(%esp)
c0104287:	e8 a8 1a 00 00       	call   c0105d34 <memset>
    boot_cr3 = PADDR(boot_pgdir);
c010428c:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104291:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104294:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010429b:	77 23                	ja     c01042c0 <pmm_init+0x70>
c010429d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01042a4:	c7 44 24 08 20 6a 10 	movl   $0xc0106a20,0x8(%esp)
c01042ab:	c0 
c01042ac:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c01042b3:	00 
c01042b4:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c01042bb:	e8 06 ca ff ff       	call   c0100cc6 <__panic>
c01042c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042c3:	05 00 00 00 40       	add    $0x40000000,%eax
c01042c8:	a3 60 89 11 c0       	mov    %eax,0xc0118960

    check_pgdir();
c01042cd:	e8 17 04 00 00       	call   c01046e9 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01042d2:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01042d7:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c01042dd:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01042e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01042e5:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01042ec:	77 23                	ja     c0104311 <pmm_init+0xc1>
c01042ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01042f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01042f5:	c7 44 24 08 20 6a 10 	movl   $0xc0106a20,0x8(%esp)
c01042fc:	c0 
c01042fd:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
c0104304:	00 
c0104305:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c010430c:	e8 b5 c9 ff ff       	call   c0100cc6 <__panic>
c0104311:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104314:	05 00 00 00 40       	add    $0x40000000,%eax
c0104319:	83 c8 03             	or     $0x3,%eax
c010431c:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    //linear_addr KERNBASE~KERNBASE+KMEMSIZE = phy_addr 0~KMEMSIZE
    //But shouldn't use this map until enable_paging() & gdt_init() finished.
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c010431e:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104323:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c010432a:	00 
c010432b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104332:	00 
c0104333:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c010433a:	38 
c010433b:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0104342:	c0 
c0104343:	89 04 24             	mov    %eax,(%esp)
c0104346:	e8 b4 fd ff ff       	call   c01040ff <boot_map_segment>

    //temporary map: 
    //virtual_addr 3G~3G+4M = linear_addr 0~4M = linear_addr 3G~3G+4M = phy_addr 0~4M     
    boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)];
c010434b:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104350:	8b 15 c4 88 11 c0    	mov    0xc01188c4,%edx
c0104356:	8b 92 00 0c 00 00    	mov    0xc00(%edx),%edx
c010435c:	89 10                	mov    %edx,(%eax)

    enable_paging();
c010435e:	e8 63 fd ff ff       	call   c01040c6 <enable_paging>

    //reload gdt(third time,the last time) to map all physical memory
    //virtual_addr 0~4G=liear_addr 0~4G
    //then set kernel stack(ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0104363:	e8 97 f7 ff ff       	call   c0103aff <gdt_init>

    //disable the map of virtual_addr 0~4M
    boot_pgdir[0] = 0;
c0104368:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c010436d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0104373:	e8 0c 0a 00 00       	call   c0104d84 <check_boot_pgdir>

    print_pgdir();
c0104378:	e8 99 0e 00 00       	call   c0105216 <print_pgdir>

}
c010437d:	c9                   	leave  
c010437e:	c3                   	ret    

c010437f <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c010437f:	55                   	push   %ebp
c0104380:	89 e5                	mov    %esp,%ebp
c0104382:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c0104385:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104388:	c1 e8 16             	shr    $0x16,%eax
c010438b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104392:	8b 45 08             	mov    0x8(%ebp),%eax
c0104395:	01 d0                	add    %edx,%eax
c0104397:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c010439a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010439d:	8b 00                	mov    (%eax),%eax
c010439f:	83 e0 01             	and    $0x1,%eax
c01043a2:	85 c0                	test   %eax,%eax
c01043a4:	0f 85 af 00 00 00    	jne    c0104459 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c01043aa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01043ae:	74 15                	je     c01043c5 <get_pte+0x46>
c01043b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01043b7:	e8 84 f8 ff ff       	call   c0103c40 <alloc_pages>
c01043bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01043bf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01043c3:	75 0a                	jne    c01043cf <get_pte+0x50>
            return NULL;
c01043c5:	b8 00 00 00 00       	mov    $0x0,%eax
c01043ca:	e9 e6 00 00 00       	jmp    c01044b5 <get_pte+0x136>
        }
        set_page_ref(page, 1);
c01043cf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01043d6:	00 
c01043d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043da:	89 04 24             	mov    %eax,(%esp)
c01043dd:	e8 63 f6 ff ff       	call   c0103a45 <set_page_ref>
        uintptr_t pa = page2pa(page);
c01043e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043e5:	89 04 24             	mov    %eax,(%esp)
c01043e8:	e8 57 f5 ff ff       	call   c0103944 <page2pa>
c01043ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c01043f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01043f3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01043f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01043f9:	c1 e8 0c             	shr    $0xc,%eax
c01043fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01043ff:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c0104404:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0104407:	72 23                	jb     c010442c <get_pte+0xad>
c0104409:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010440c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104410:	c7 44 24 08 7c 69 10 	movl   $0xc010697c,0x8(%esp)
c0104417:	c0 
c0104418:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
c010441f:	00 
c0104420:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104427:	e8 9a c8 ff ff       	call   c0100cc6 <__panic>
c010442c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010442f:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104434:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010443b:	00 
c010443c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104443:	00 
c0104444:	89 04 24             	mov    %eax,(%esp)
c0104447:	e8 e8 18 00 00       	call   c0105d34 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c010444c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010444f:	83 c8 07             	or     $0x7,%eax
c0104452:	89 c2                	mov    %eax,%edx
c0104454:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104457:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0104459:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010445c:	8b 00                	mov    (%eax),%eax
c010445e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104463:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104466:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104469:	c1 e8 0c             	shr    $0xc,%eax
c010446c:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010446f:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c0104474:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104477:	72 23                	jb     c010449c <get_pte+0x11d>
c0104479:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010447c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104480:	c7 44 24 08 7c 69 10 	movl   $0xc010697c,0x8(%esp)
c0104487:	c0 
c0104488:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
c010448f:	00 
c0104490:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104497:	e8 2a c8 ff ff       	call   c0100cc6 <__panic>
c010449c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010449f:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01044a4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01044a7:	c1 ea 0c             	shr    $0xc,%edx
c01044aa:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c01044b0:	c1 e2 02             	shl    $0x2,%edx
c01044b3:	01 d0                	add    %edx,%eax
}
c01044b5:	c9                   	leave  
c01044b6:	c3                   	ret    

c01044b7 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01044b7:	55                   	push   %ebp
c01044b8:	89 e5                	mov    %esp,%ebp
c01044ba:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01044bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01044c4:	00 
c01044c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01044c8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01044cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01044cf:	89 04 24             	mov    %eax,(%esp)
c01044d2:	e8 a8 fe ff ff       	call   c010437f <get_pte>
c01044d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01044da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01044de:	74 08                	je     c01044e8 <get_page+0x31>
        *ptep_store = ptep;
c01044e0:	8b 45 10             	mov    0x10(%ebp),%eax
c01044e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01044e6:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c01044e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01044ec:	74 1b                	je     c0104509 <get_page+0x52>
c01044ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044f1:	8b 00                	mov    (%eax),%eax
c01044f3:	83 e0 01             	and    $0x1,%eax
c01044f6:	85 c0                	test   %eax,%eax
c01044f8:	74 0f                	je     c0104509 <get_page+0x52>
        return pa2page(*ptep);
c01044fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044fd:	8b 00                	mov    (%eax),%eax
c01044ff:	89 04 24             	mov    %eax,(%esp)
c0104502:	e8 53 f4 ff ff       	call   c010395a <pa2page>
c0104507:	eb 05                	jmp    c010450e <get_page+0x57>
    }
    return NULL;
c0104509:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010450e:	c9                   	leave  
c010450f:	c3                   	ret    

c0104510 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0104510:	55                   	push   %ebp
c0104511:	89 e5                	mov    %esp,%ebp
c0104513:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c0104516:	8b 45 10             	mov    0x10(%ebp),%eax
c0104519:	8b 00                	mov    (%eax),%eax
c010451b:	83 e0 01             	and    $0x1,%eax
c010451e:	85 c0                	test   %eax,%eax
c0104520:	74 4d                	je     c010456f <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c0104522:	8b 45 10             	mov    0x10(%ebp),%eax
c0104525:	8b 00                	mov    (%eax),%eax
c0104527:	89 04 24             	mov    %eax,(%esp)
c010452a:	e8 ce f4 ff ff       	call   c01039fd <pte2page>
c010452f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0104532:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104535:	89 04 24             	mov    %eax,(%esp)
c0104538:	e8 2c f5 ff ff       	call   c0103a69 <page_ref_dec>
c010453d:	85 c0                	test   %eax,%eax
c010453f:	75 13                	jne    c0104554 <page_remove_pte+0x44>
            free_page(page);
c0104541:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104548:	00 
c0104549:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010454c:	89 04 24             	mov    %eax,(%esp)
c010454f:	e8 24 f7 ff ff       	call   c0103c78 <free_pages>
        }
        *ptep = 0;
c0104554:	8b 45 10             	mov    0x10(%ebp),%eax
c0104557:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c010455d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104560:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104564:	8b 45 08             	mov    0x8(%ebp),%eax
c0104567:	89 04 24             	mov    %eax,(%esp)
c010456a:	e8 ff 00 00 00       	call   c010466e <tlb_invalidate>
    }
}
c010456f:	c9                   	leave  
c0104570:	c3                   	ret    

c0104571 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0104571:	55                   	push   %ebp
c0104572:	89 e5                	mov    %esp,%ebp
c0104574:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104577:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010457e:	00 
c010457f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104582:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104586:	8b 45 08             	mov    0x8(%ebp),%eax
c0104589:	89 04 24             	mov    %eax,(%esp)
c010458c:	e8 ee fd ff ff       	call   c010437f <get_pte>
c0104591:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0104594:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104598:	74 19                	je     c01045b3 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c010459a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010459d:	89 44 24 08          	mov    %eax,0x8(%esp)
c01045a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01045a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01045a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01045ab:	89 04 24             	mov    %eax,(%esp)
c01045ae:	e8 5d ff ff ff       	call   c0104510 <page_remove_pte>
    }
}
c01045b3:	c9                   	leave  
c01045b4:	c3                   	ret    

c01045b5 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01045b5:	55                   	push   %ebp
c01045b6:	89 e5                	mov    %esp,%ebp
c01045b8:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01045bb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01045c2:	00 
c01045c3:	8b 45 10             	mov    0x10(%ebp),%eax
c01045c6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01045ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01045cd:	89 04 24             	mov    %eax,(%esp)
c01045d0:	e8 aa fd ff ff       	call   c010437f <get_pte>
c01045d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01045d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01045dc:	75 0a                	jne    c01045e8 <page_insert+0x33>
        return -E_NO_MEM;
c01045de:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01045e3:	e9 84 00 00 00       	jmp    c010466c <page_insert+0xb7>
    }
    page_ref_inc(page);
c01045e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01045eb:	89 04 24             	mov    %eax,(%esp)
c01045ee:	e8 5f f4 ff ff       	call   c0103a52 <page_ref_inc>
    if (*ptep & PTE_P) {
c01045f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045f6:	8b 00                	mov    (%eax),%eax
c01045f8:	83 e0 01             	and    $0x1,%eax
c01045fb:	85 c0                	test   %eax,%eax
c01045fd:	74 3e                	je     c010463d <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c01045ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104602:	8b 00                	mov    (%eax),%eax
c0104604:	89 04 24             	mov    %eax,(%esp)
c0104607:	e8 f1 f3 ff ff       	call   c01039fd <pte2page>
c010460c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010460f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104612:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104615:	75 0d                	jne    c0104624 <page_insert+0x6f>
            page_ref_dec(page);
c0104617:	8b 45 0c             	mov    0xc(%ebp),%eax
c010461a:	89 04 24             	mov    %eax,(%esp)
c010461d:	e8 47 f4 ff ff       	call   c0103a69 <page_ref_dec>
c0104622:	eb 19                	jmp    c010463d <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0104624:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104627:	89 44 24 08          	mov    %eax,0x8(%esp)
c010462b:	8b 45 10             	mov    0x10(%ebp),%eax
c010462e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104632:	8b 45 08             	mov    0x8(%ebp),%eax
c0104635:	89 04 24             	mov    %eax,(%esp)
c0104638:	e8 d3 fe ff ff       	call   c0104510 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c010463d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104640:	89 04 24             	mov    %eax,(%esp)
c0104643:	e8 fc f2 ff ff       	call   c0103944 <page2pa>
c0104648:	0b 45 14             	or     0x14(%ebp),%eax
c010464b:	83 c8 01             	or     $0x1,%eax
c010464e:	89 c2                	mov    %eax,%edx
c0104650:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104653:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0104655:	8b 45 10             	mov    0x10(%ebp),%eax
c0104658:	89 44 24 04          	mov    %eax,0x4(%esp)
c010465c:	8b 45 08             	mov    0x8(%ebp),%eax
c010465f:	89 04 24             	mov    %eax,(%esp)
c0104662:	e8 07 00 00 00       	call   c010466e <tlb_invalidate>
    return 0;
c0104667:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010466c:	c9                   	leave  
c010466d:	c3                   	ret    

c010466e <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c010466e:	55                   	push   %ebp
c010466f:	89 e5                	mov    %esp,%ebp
c0104671:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0104674:	0f 20 d8             	mov    %cr3,%eax
c0104677:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c010467a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c010467d:	89 c2                	mov    %eax,%edx
c010467f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104682:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104685:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010468c:	77 23                	ja     c01046b1 <tlb_invalidate+0x43>
c010468e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104691:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104695:	c7 44 24 08 20 6a 10 	movl   $0xc0106a20,0x8(%esp)
c010469c:	c0 
c010469d:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c01046a4:	00 
c01046a5:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c01046ac:	e8 15 c6 ff ff       	call   c0100cc6 <__panic>
c01046b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046b4:	05 00 00 00 40       	add    $0x40000000,%eax
c01046b9:	39 c2                	cmp    %eax,%edx
c01046bb:	75 0c                	jne    c01046c9 <tlb_invalidate+0x5b>
        invlpg((void *)la);
c01046bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01046c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01046c6:	0f 01 38             	invlpg (%eax)
    }
}
c01046c9:	c9                   	leave  
c01046ca:	c3                   	ret    

c01046cb <check_alloc_page>:

static void
check_alloc_page(void) {
c01046cb:	55                   	push   %ebp
c01046cc:	89 e5                	mov    %esp,%ebp
c01046ce:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01046d1:	a1 5c 89 11 c0       	mov    0xc011895c,%eax
c01046d6:	8b 40 18             	mov    0x18(%eax),%eax
c01046d9:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01046db:	c7 04 24 a4 6a 10 c0 	movl   $0xc0106aa4,(%esp)
c01046e2:	e8 55 bc ff ff       	call   c010033c <cprintf>
}
c01046e7:	c9                   	leave  
c01046e8:	c3                   	ret    

c01046e9 <check_pgdir>:

static void
check_pgdir(void) {
c01046e9:	55                   	push   %ebp
c01046ea:	89 e5                	mov    %esp,%ebp
c01046ec:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01046ef:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c01046f4:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01046f9:	76 24                	jbe    c010471f <check_pgdir+0x36>
c01046fb:	c7 44 24 0c c3 6a 10 	movl   $0xc0106ac3,0xc(%esp)
c0104702:	c0 
c0104703:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c010470a:	c0 
c010470b:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0104712:	00 
c0104713:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c010471a:	e8 a7 c5 ff ff       	call   c0100cc6 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c010471f:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104724:	85 c0                	test   %eax,%eax
c0104726:	74 0e                	je     c0104736 <check_pgdir+0x4d>
c0104728:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c010472d:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104732:	85 c0                	test   %eax,%eax
c0104734:	74 24                	je     c010475a <check_pgdir+0x71>
c0104736:	c7 44 24 0c e0 6a 10 	movl   $0xc0106ae0,0xc(%esp)
c010473d:	c0 
c010473e:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104745:	c0 
c0104746:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c010474d:	00 
c010474e:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104755:	e8 6c c5 ff ff       	call   c0100cc6 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c010475a:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c010475f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104766:	00 
c0104767:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010476e:	00 
c010476f:	89 04 24             	mov    %eax,(%esp)
c0104772:	e8 40 fd ff ff       	call   c01044b7 <get_page>
c0104777:	85 c0                	test   %eax,%eax
c0104779:	74 24                	je     c010479f <check_pgdir+0xb6>
c010477b:	c7 44 24 0c 18 6b 10 	movl   $0xc0106b18,0xc(%esp)
c0104782:	c0 
c0104783:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c010478a:	c0 
c010478b:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c0104792:	00 
c0104793:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c010479a:	e8 27 c5 ff ff       	call   c0100cc6 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c010479f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01047a6:	e8 95 f4 ff ff       	call   c0103c40 <alloc_pages>
c01047ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01047ae:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01047b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01047ba:	00 
c01047bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01047c2:	00 
c01047c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01047c6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01047ca:	89 04 24             	mov    %eax,(%esp)
c01047cd:	e8 e3 fd ff ff       	call   c01045b5 <page_insert>
c01047d2:	85 c0                	test   %eax,%eax
c01047d4:	74 24                	je     c01047fa <check_pgdir+0x111>
c01047d6:	c7 44 24 0c 40 6b 10 	movl   $0xc0106b40,0xc(%esp)
c01047dd:	c0 
c01047de:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c01047e5:	c0 
c01047e6:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c01047ed:	00 
c01047ee:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c01047f5:	e8 cc c4 ff ff       	call   c0100cc6 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01047fa:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01047ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104806:	00 
c0104807:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010480e:	00 
c010480f:	89 04 24             	mov    %eax,(%esp)
c0104812:	e8 68 fb ff ff       	call   c010437f <get_pte>
c0104817:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010481a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010481e:	75 24                	jne    c0104844 <check_pgdir+0x15b>
c0104820:	c7 44 24 0c 6c 6b 10 	movl   $0xc0106b6c,0xc(%esp)
c0104827:	c0 
c0104828:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c010482f:	c0 
c0104830:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c0104837:	00 
c0104838:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c010483f:	e8 82 c4 ff ff       	call   c0100cc6 <__panic>
    assert(pa2page(*ptep) == p1);
c0104844:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104847:	8b 00                	mov    (%eax),%eax
c0104849:	89 04 24             	mov    %eax,(%esp)
c010484c:	e8 09 f1 ff ff       	call   c010395a <pa2page>
c0104851:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104854:	74 24                	je     c010487a <check_pgdir+0x191>
c0104856:	c7 44 24 0c 99 6b 10 	movl   $0xc0106b99,0xc(%esp)
c010485d:	c0 
c010485e:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104865:	c0 
c0104866:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c010486d:	00 
c010486e:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104875:	e8 4c c4 ff ff       	call   c0100cc6 <__panic>
    assert(page_ref(p1) == 1);
c010487a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010487d:	89 04 24             	mov    %eax,(%esp)
c0104880:	e8 b6 f1 ff ff       	call   c0103a3b <page_ref>
c0104885:	83 f8 01             	cmp    $0x1,%eax
c0104888:	74 24                	je     c01048ae <check_pgdir+0x1c5>
c010488a:	c7 44 24 0c ae 6b 10 	movl   $0xc0106bae,0xc(%esp)
c0104891:	c0 
c0104892:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104899:	c0 
c010489a:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c01048a1:	00 
c01048a2:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c01048a9:	e8 18 c4 ff ff       	call   c0100cc6 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01048ae:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01048b3:	8b 00                	mov    (%eax),%eax
c01048b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01048ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01048bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048c0:	c1 e8 0c             	shr    $0xc,%eax
c01048c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01048c6:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c01048cb:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01048ce:	72 23                	jb     c01048f3 <check_pgdir+0x20a>
c01048d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01048d7:	c7 44 24 08 7c 69 10 	movl   $0xc010697c,0x8(%esp)
c01048de:	c0 
c01048df:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
c01048e6:	00 
c01048e7:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c01048ee:	e8 d3 c3 ff ff       	call   c0100cc6 <__panic>
c01048f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048f6:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01048fb:	83 c0 04             	add    $0x4,%eax
c01048fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0104901:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104906:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010490d:	00 
c010490e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104915:	00 
c0104916:	89 04 24             	mov    %eax,(%esp)
c0104919:	e8 61 fa ff ff       	call   c010437f <get_pte>
c010491e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104921:	74 24                	je     c0104947 <check_pgdir+0x25e>
c0104923:	c7 44 24 0c c0 6b 10 	movl   $0xc0106bc0,0xc(%esp)
c010492a:	c0 
c010492b:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104932:	c0 
c0104933:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c010493a:	00 
c010493b:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104942:	e8 7f c3 ff ff       	call   c0100cc6 <__panic>

    p2 = alloc_page();
c0104947:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010494e:	e8 ed f2 ff ff       	call   c0103c40 <alloc_pages>
c0104953:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0104956:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c010495b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0104962:	00 
c0104963:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010496a:	00 
c010496b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010496e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104972:	89 04 24             	mov    %eax,(%esp)
c0104975:	e8 3b fc ff ff       	call   c01045b5 <page_insert>
c010497a:	85 c0                	test   %eax,%eax
c010497c:	74 24                	je     c01049a2 <check_pgdir+0x2b9>
c010497e:	c7 44 24 0c e8 6b 10 	movl   $0xc0106be8,0xc(%esp)
c0104985:	c0 
c0104986:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c010498d:	c0 
c010498e:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c0104995:	00 
c0104996:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c010499d:	e8 24 c3 ff ff       	call   c0100cc6 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01049a2:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01049a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01049ae:	00 
c01049af:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01049b6:	00 
c01049b7:	89 04 24             	mov    %eax,(%esp)
c01049ba:	e8 c0 f9 ff ff       	call   c010437f <get_pte>
c01049bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01049c2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01049c6:	75 24                	jne    c01049ec <check_pgdir+0x303>
c01049c8:	c7 44 24 0c 20 6c 10 	movl   $0xc0106c20,0xc(%esp)
c01049cf:	c0 
c01049d0:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c01049d7:	c0 
c01049d8:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c01049df:	00 
c01049e0:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c01049e7:	e8 da c2 ff ff       	call   c0100cc6 <__panic>
    assert(*ptep & PTE_U);
c01049ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049ef:	8b 00                	mov    (%eax),%eax
c01049f1:	83 e0 04             	and    $0x4,%eax
c01049f4:	85 c0                	test   %eax,%eax
c01049f6:	75 24                	jne    c0104a1c <check_pgdir+0x333>
c01049f8:	c7 44 24 0c 50 6c 10 	movl   $0xc0106c50,0xc(%esp)
c01049ff:	c0 
c0104a00:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104a07:	c0 
c0104a08:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0104a0f:	00 
c0104a10:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104a17:	e8 aa c2 ff ff       	call   c0100cc6 <__panic>
    assert(*ptep & PTE_W);
c0104a1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a1f:	8b 00                	mov    (%eax),%eax
c0104a21:	83 e0 02             	and    $0x2,%eax
c0104a24:	85 c0                	test   %eax,%eax
c0104a26:	75 24                	jne    c0104a4c <check_pgdir+0x363>
c0104a28:	c7 44 24 0c 5e 6c 10 	movl   $0xc0106c5e,0xc(%esp)
c0104a2f:	c0 
c0104a30:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104a37:	c0 
c0104a38:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0104a3f:	00 
c0104a40:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104a47:	e8 7a c2 ff ff       	call   c0100cc6 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0104a4c:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104a51:	8b 00                	mov    (%eax),%eax
c0104a53:	83 e0 04             	and    $0x4,%eax
c0104a56:	85 c0                	test   %eax,%eax
c0104a58:	75 24                	jne    c0104a7e <check_pgdir+0x395>
c0104a5a:	c7 44 24 0c 6c 6c 10 	movl   $0xc0106c6c,0xc(%esp)
c0104a61:	c0 
c0104a62:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104a69:	c0 
c0104a6a:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0104a71:	00 
c0104a72:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104a79:	e8 48 c2 ff ff       	call   c0100cc6 <__panic>
    assert(page_ref(p2) == 1);
c0104a7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a81:	89 04 24             	mov    %eax,(%esp)
c0104a84:	e8 b2 ef ff ff       	call   c0103a3b <page_ref>
c0104a89:	83 f8 01             	cmp    $0x1,%eax
c0104a8c:	74 24                	je     c0104ab2 <check_pgdir+0x3c9>
c0104a8e:	c7 44 24 0c 82 6c 10 	movl   $0xc0106c82,0xc(%esp)
c0104a95:	c0 
c0104a96:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104a9d:	c0 
c0104a9e:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0104aa5:	00 
c0104aa6:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104aad:	e8 14 c2 ff ff       	call   c0100cc6 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0104ab2:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104ab7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104abe:	00 
c0104abf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104ac6:	00 
c0104ac7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104aca:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104ace:	89 04 24             	mov    %eax,(%esp)
c0104ad1:	e8 df fa ff ff       	call   c01045b5 <page_insert>
c0104ad6:	85 c0                	test   %eax,%eax
c0104ad8:	74 24                	je     c0104afe <check_pgdir+0x415>
c0104ada:	c7 44 24 0c 94 6c 10 	movl   $0xc0106c94,0xc(%esp)
c0104ae1:	c0 
c0104ae2:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104ae9:	c0 
c0104aea:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c0104af1:	00 
c0104af2:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104af9:	e8 c8 c1 ff ff       	call   c0100cc6 <__panic>
    assert(page_ref(p1) == 2);
c0104afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b01:	89 04 24             	mov    %eax,(%esp)
c0104b04:	e8 32 ef ff ff       	call   c0103a3b <page_ref>
c0104b09:	83 f8 02             	cmp    $0x2,%eax
c0104b0c:	74 24                	je     c0104b32 <check_pgdir+0x449>
c0104b0e:	c7 44 24 0c c0 6c 10 	movl   $0xc0106cc0,0xc(%esp)
c0104b15:	c0 
c0104b16:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104b1d:	c0 
c0104b1e:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0104b25:	00 
c0104b26:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104b2d:	e8 94 c1 ff ff       	call   c0100cc6 <__panic>
    assert(page_ref(p2) == 0);
c0104b32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b35:	89 04 24             	mov    %eax,(%esp)
c0104b38:	e8 fe ee ff ff       	call   c0103a3b <page_ref>
c0104b3d:	85 c0                	test   %eax,%eax
c0104b3f:	74 24                	je     c0104b65 <check_pgdir+0x47c>
c0104b41:	c7 44 24 0c d2 6c 10 	movl   $0xc0106cd2,0xc(%esp)
c0104b48:	c0 
c0104b49:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104b50:	c0 
c0104b51:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c0104b58:	00 
c0104b59:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104b60:	e8 61 c1 ff ff       	call   c0100cc6 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104b65:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104b6a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104b71:	00 
c0104b72:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104b79:	00 
c0104b7a:	89 04 24             	mov    %eax,(%esp)
c0104b7d:	e8 fd f7 ff ff       	call   c010437f <get_pte>
c0104b82:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104b85:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104b89:	75 24                	jne    c0104baf <check_pgdir+0x4c6>
c0104b8b:	c7 44 24 0c 20 6c 10 	movl   $0xc0106c20,0xc(%esp)
c0104b92:	c0 
c0104b93:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104b9a:	c0 
c0104b9b:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0104ba2:	00 
c0104ba3:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104baa:	e8 17 c1 ff ff       	call   c0100cc6 <__panic>
    assert(pa2page(*ptep) == p1);
c0104baf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bb2:	8b 00                	mov    (%eax),%eax
c0104bb4:	89 04 24             	mov    %eax,(%esp)
c0104bb7:	e8 9e ed ff ff       	call   c010395a <pa2page>
c0104bbc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104bbf:	74 24                	je     c0104be5 <check_pgdir+0x4fc>
c0104bc1:	c7 44 24 0c 99 6b 10 	movl   $0xc0106b99,0xc(%esp)
c0104bc8:	c0 
c0104bc9:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104bd0:	c0 
c0104bd1:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c0104bd8:	00 
c0104bd9:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104be0:	e8 e1 c0 ff ff       	call   c0100cc6 <__panic>
    assert((*ptep & PTE_U) == 0);
c0104be5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104be8:	8b 00                	mov    (%eax),%eax
c0104bea:	83 e0 04             	and    $0x4,%eax
c0104bed:	85 c0                	test   %eax,%eax
c0104bef:	74 24                	je     c0104c15 <check_pgdir+0x52c>
c0104bf1:	c7 44 24 0c e4 6c 10 	movl   $0xc0106ce4,0xc(%esp)
c0104bf8:	c0 
c0104bf9:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104c00:	c0 
c0104c01:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c0104c08:	00 
c0104c09:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104c10:	e8 b1 c0 ff ff       	call   c0100cc6 <__panic>

    page_remove(boot_pgdir, 0x0);
c0104c15:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104c1a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104c21:	00 
c0104c22:	89 04 24             	mov    %eax,(%esp)
c0104c25:	e8 47 f9 ff ff       	call   c0104571 <page_remove>
    assert(page_ref(p1) == 1);
c0104c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c2d:	89 04 24             	mov    %eax,(%esp)
c0104c30:	e8 06 ee ff ff       	call   c0103a3b <page_ref>
c0104c35:	83 f8 01             	cmp    $0x1,%eax
c0104c38:	74 24                	je     c0104c5e <check_pgdir+0x575>
c0104c3a:	c7 44 24 0c ae 6b 10 	movl   $0xc0106bae,0xc(%esp)
c0104c41:	c0 
c0104c42:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104c49:	c0 
c0104c4a:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0104c51:	00 
c0104c52:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104c59:	e8 68 c0 ff ff       	call   c0100cc6 <__panic>
    assert(page_ref(p2) == 0);
c0104c5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c61:	89 04 24             	mov    %eax,(%esp)
c0104c64:	e8 d2 ed ff ff       	call   c0103a3b <page_ref>
c0104c69:	85 c0                	test   %eax,%eax
c0104c6b:	74 24                	je     c0104c91 <check_pgdir+0x5a8>
c0104c6d:	c7 44 24 0c d2 6c 10 	movl   $0xc0106cd2,0xc(%esp)
c0104c74:	c0 
c0104c75:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104c7c:	c0 
c0104c7d:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c0104c84:	00 
c0104c85:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104c8c:	e8 35 c0 ff ff       	call   c0100cc6 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0104c91:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104c96:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104c9d:	00 
c0104c9e:	89 04 24             	mov    %eax,(%esp)
c0104ca1:	e8 cb f8 ff ff       	call   c0104571 <page_remove>
    assert(page_ref(p1) == 0);
c0104ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ca9:	89 04 24             	mov    %eax,(%esp)
c0104cac:	e8 8a ed ff ff       	call   c0103a3b <page_ref>
c0104cb1:	85 c0                	test   %eax,%eax
c0104cb3:	74 24                	je     c0104cd9 <check_pgdir+0x5f0>
c0104cb5:	c7 44 24 0c f9 6c 10 	movl   $0xc0106cf9,0xc(%esp)
c0104cbc:	c0 
c0104cbd:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104cc4:	c0 
c0104cc5:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c0104ccc:	00 
c0104ccd:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104cd4:	e8 ed bf ff ff       	call   c0100cc6 <__panic>
    assert(page_ref(p2) == 0);
c0104cd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104cdc:	89 04 24             	mov    %eax,(%esp)
c0104cdf:	e8 57 ed ff ff       	call   c0103a3b <page_ref>
c0104ce4:	85 c0                	test   %eax,%eax
c0104ce6:	74 24                	je     c0104d0c <check_pgdir+0x623>
c0104ce8:	c7 44 24 0c d2 6c 10 	movl   $0xc0106cd2,0xc(%esp)
c0104cef:	c0 
c0104cf0:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104cf7:	c0 
c0104cf8:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0104cff:	00 
c0104d00:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104d07:	e8 ba bf ff ff       	call   c0100cc6 <__panic>

    assert(page_ref(pa2page(boot_pgdir[0])) == 1);
c0104d0c:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104d11:	8b 00                	mov    (%eax),%eax
c0104d13:	89 04 24             	mov    %eax,(%esp)
c0104d16:	e8 3f ec ff ff       	call   c010395a <pa2page>
c0104d1b:	89 04 24             	mov    %eax,(%esp)
c0104d1e:	e8 18 ed ff ff       	call   c0103a3b <page_ref>
c0104d23:	83 f8 01             	cmp    $0x1,%eax
c0104d26:	74 24                	je     c0104d4c <check_pgdir+0x663>
c0104d28:	c7 44 24 0c 0c 6d 10 	movl   $0xc0106d0c,0xc(%esp)
c0104d2f:	c0 
c0104d30:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104d37:	c0 
c0104d38:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c0104d3f:	00 
c0104d40:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104d47:	e8 7a bf ff ff       	call   c0100cc6 <__panic>
    free_page(pa2page(boot_pgdir[0]));
c0104d4c:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104d51:	8b 00                	mov    (%eax),%eax
c0104d53:	89 04 24             	mov    %eax,(%esp)
c0104d56:	e8 ff eb ff ff       	call   c010395a <pa2page>
c0104d5b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d62:	00 
c0104d63:	89 04 24             	mov    %eax,(%esp)
c0104d66:	e8 0d ef ff ff       	call   c0103c78 <free_pages>
    boot_pgdir[0] = 0;
c0104d6b:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104d70:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0104d76:	c7 04 24 32 6d 10 c0 	movl   $0xc0106d32,(%esp)
c0104d7d:	e8 ba b5 ff ff       	call   c010033c <cprintf>
}
c0104d82:	c9                   	leave  
c0104d83:	c3                   	ret    

c0104d84 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0104d84:	55                   	push   %ebp
c0104d85:	89 e5                	mov    %esp,%ebp
c0104d87:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104d8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104d91:	e9 ca 00 00 00       	jmp    c0104e60 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0104d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d99:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d9f:	c1 e8 0c             	shr    $0xc,%eax
c0104da2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104da5:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c0104daa:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104dad:	72 23                	jb     c0104dd2 <check_boot_pgdir+0x4e>
c0104daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104db2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104db6:	c7 44 24 08 7c 69 10 	movl   $0xc010697c,0x8(%esp)
c0104dbd:	c0 
c0104dbe:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c0104dc5:	00 
c0104dc6:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104dcd:	e8 f4 be ff ff       	call   c0100cc6 <__panic>
c0104dd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104dd5:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104dda:	89 c2                	mov    %eax,%edx
c0104ddc:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104de1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104de8:	00 
c0104de9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104ded:	89 04 24             	mov    %eax,(%esp)
c0104df0:	e8 8a f5 ff ff       	call   c010437f <get_pte>
c0104df5:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104df8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104dfc:	75 24                	jne    c0104e22 <check_boot_pgdir+0x9e>
c0104dfe:	c7 44 24 0c 4c 6d 10 	movl   $0xc0106d4c,0xc(%esp)
c0104e05:	c0 
c0104e06:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104e0d:	c0 
c0104e0e:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c0104e15:	00 
c0104e16:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104e1d:	e8 a4 be ff ff       	call   c0100cc6 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0104e22:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e25:	8b 00                	mov    (%eax),%eax
c0104e27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e2c:	89 c2                	mov    %eax,%edx
c0104e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e31:	39 c2                	cmp    %eax,%edx
c0104e33:	74 24                	je     c0104e59 <check_boot_pgdir+0xd5>
c0104e35:	c7 44 24 0c 89 6d 10 	movl   $0xc0106d89,0xc(%esp)
c0104e3c:	c0 
c0104e3d:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104e44:	c0 
c0104e45:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c0104e4c:	00 
c0104e4d:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104e54:	e8 6d be ff ff       	call   c0100cc6 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104e59:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0104e60:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104e63:	a1 c0 88 11 c0       	mov    0xc01188c0,%eax
c0104e68:	39 c2                	cmp    %eax,%edx
c0104e6a:	0f 82 26 ff ff ff    	jb     c0104d96 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0104e70:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104e75:	05 ac 0f 00 00       	add    $0xfac,%eax
c0104e7a:	8b 00                	mov    (%eax),%eax
c0104e7c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e81:	89 c2                	mov    %eax,%edx
c0104e83:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104e88:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104e8b:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0104e92:	77 23                	ja     c0104eb7 <check_boot_pgdir+0x133>
c0104e94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e97:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104e9b:	c7 44 24 08 20 6a 10 	movl   $0xc0106a20,0x8(%esp)
c0104ea2:	c0 
c0104ea3:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c0104eaa:	00 
c0104eab:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104eb2:	e8 0f be ff ff       	call   c0100cc6 <__panic>
c0104eb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104eba:	05 00 00 00 40       	add    $0x40000000,%eax
c0104ebf:	39 c2                	cmp    %eax,%edx
c0104ec1:	74 24                	je     c0104ee7 <check_boot_pgdir+0x163>
c0104ec3:	c7 44 24 0c a0 6d 10 	movl   $0xc0106da0,0xc(%esp)
c0104eca:	c0 
c0104ecb:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104ed2:	c0 
c0104ed3:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c0104eda:	00 
c0104edb:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104ee2:	e8 df bd ff ff       	call   c0100cc6 <__panic>

    assert(boot_pgdir[0] == 0);
c0104ee7:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104eec:	8b 00                	mov    (%eax),%eax
c0104eee:	85 c0                	test   %eax,%eax
c0104ef0:	74 24                	je     c0104f16 <check_boot_pgdir+0x192>
c0104ef2:	c7 44 24 0c d4 6d 10 	movl   $0xc0106dd4,0xc(%esp)
c0104ef9:	c0 
c0104efa:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104f01:	c0 
c0104f02:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
c0104f09:	00 
c0104f0a:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104f11:	e8 b0 bd ff ff       	call   c0100cc6 <__panic>

    struct Page *p;
    p = alloc_page();
c0104f16:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104f1d:	e8 1e ed ff ff       	call   c0103c40 <alloc_pages>
c0104f22:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0104f25:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104f2a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104f31:	00 
c0104f32:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0104f39:	00 
c0104f3a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104f3d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104f41:	89 04 24             	mov    %eax,(%esp)
c0104f44:	e8 6c f6 ff ff       	call   c01045b5 <page_insert>
c0104f49:	85 c0                	test   %eax,%eax
c0104f4b:	74 24                	je     c0104f71 <check_boot_pgdir+0x1ed>
c0104f4d:	c7 44 24 0c e8 6d 10 	movl   $0xc0106de8,0xc(%esp)
c0104f54:	c0 
c0104f55:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104f5c:	c0 
c0104f5d:	c7 44 24 04 36 02 00 	movl   $0x236,0x4(%esp)
c0104f64:	00 
c0104f65:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104f6c:	e8 55 bd ff ff       	call   c0100cc6 <__panic>
    assert(page_ref(p) == 1);
c0104f71:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104f74:	89 04 24             	mov    %eax,(%esp)
c0104f77:	e8 bf ea ff ff       	call   c0103a3b <page_ref>
c0104f7c:	83 f8 01             	cmp    $0x1,%eax
c0104f7f:	74 24                	je     c0104fa5 <check_boot_pgdir+0x221>
c0104f81:	c7 44 24 0c 16 6e 10 	movl   $0xc0106e16,0xc(%esp)
c0104f88:	c0 
c0104f89:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104f90:	c0 
c0104f91:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
c0104f98:	00 
c0104f99:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104fa0:	e8 21 bd ff ff       	call   c0100cc6 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0104fa5:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c0104faa:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104fb1:	00 
c0104fb2:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0104fb9:	00 
c0104fba:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104fbd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104fc1:	89 04 24             	mov    %eax,(%esp)
c0104fc4:	e8 ec f5 ff ff       	call   c01045b5 <page_insert>
c0104fc9:	85 c0                	test   %eax,%eax
c0104fcb:	74 24                	je     c0104ff1 <check_boot_pgdir+0x26d>
c0104fcd:	c7 44 24 0c 28 6e 10 	movl   $0xc0106e28,0xc(%esp)
c0104fd4:	c0 
c0104fd5:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104fdc:	c0 
c0104fdd:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
c0104fe4:	00 
c0104fe5:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104fec:	e8 d5 bc ff ff       	call   c0100cc6 <__panic>
    assert(page_ref(p) == 2);
c0104ff1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104ff4:	89 04 24             	mov    %eax,(%esp)
c0104ff7:	e8 3f ea ff ff       	call   c0103a3b <page_ref>
c0104ffc:	83 f8 02             	cmp    $0x2,%eax
c0104fff:	74 24                	je     c0105025 <check_boot_pgdir+0x2a1>
c0105001:	c7 44 24 0c 5f 6e 10 	movl   $0xc0106e5f,0xc(%esp)
c0105008:	c0 
c0105009:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0105010:	c0 
c0105011:	c7 44 24 04 39 02 00 	movl   $0x239,0x4(%esp)
c0105018:	00 
c0105019:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0105020:	e8 a1 bc ff ff       	call   c0100cc6 <__panic>

    const char *str = "ucore: Hello world!!";
c0105025:	c7 45 dc 70 6e 10 c0 	movl   $0xc0106e70,-0x24(%ebp)
    strcpy((void *)0x100, str);
c010502c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010502f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105033:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010503a:	e8 1e 0a 00 00       	call   c0105a5d <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c010503f:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0105046:	00 
c0105047:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010504e:	e8 83 0a 00 00       	call   c0105ad6 <strcmp>
c0105053:	85 c0                	test   %eax,%eax
c0105055:	74 24                	je     c010507b <check_boot_pgdir+0x2f7>
c0105057:	c7 44 24 0c 88 6e 10 	movl   $0xc0106e88,0xc(%esp)
c010505e:	c0 
c010505f:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0105066:	c0 
c0105067:	c7 44 24 04 3d 02 00 	movl   $0x23d,0x4(%esp)
c010506e:	00 
c010506f:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0105076:	e8 4b bc ff ff       	call   c0100cc6 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c010507b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010507e:	89 04 24             	mov    %eax,(%esp)
c0105081:	e8 23 e9 ff ff       	call   c01039a9 <page2kva>
c0105086:	05 00 01 00 00       	add    $0x100,%eax
c010508b:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c010508e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105095:	e8 6b 09 00 00       	call   c0105a05 <strlen>
c010509a:	85 c0                	test   %eax,%eax
c010509c:	74 24                	je     c01050c2 <check_boot_pgdir+0x33e>
c010509e:	c7 44 24 0c c0 6e 10 	movl   $0xc0106ec0,0xc(%esp)
c01050a5:	c0 
c01050a6:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c01050ad:	c0 
c01050ae:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
c01050b5:	00 
c01050b6:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c01050bd:	e8 04 bc ff ff       	call   c0100cc6 <__panic>

    free_page(p);
c01050c2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01050c9:	00 
c01050ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050cd:	89 04 24             	mov    %eax,(%esp)
c01050d0:	e8 a3 eb ff ff       	call   c0103c78 <free_pages>
    free_page(pa2page(PDE_ADDR(boot_pgdir[0])));
c01050d5:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01050da:	8b 00                	mov    (%eax),%eax
c01050dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01050e1:	89 04 24             	mov    %eax,(%esp)
c01050e4:	e8 71 e8 ff ff       	call   c010395a <pa2page>
c01050e9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01050f0:	00 
c01050f1:	89 04 24             	mov    %eax,(%esp)
c01050f4:	e8 7f eb ff ff       	call   c0103c78 <free_pages>
    boot_pgdir[0] = 0;
c01050f9:	a1 c4 88 11 c0       	mov    0xc01188c4,%eax
c01050fe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0105104:	c7 04 24 e4 6e 10 c0 	movl   $0xc0106ee4,(%esp)
c010510b:	e8 2c b2 ff ff       	call   c010033c <cprintf>
}
c0105110:	c9                   	leave  
c0105111:	c3                   	ret    

c0105112 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0105112:	55                   	push   %ebp
c0105113:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0105115:	8b 45 08             	mov    0x8(%ebp),%eax
c0105118:	83 e0 04             	and    $0x4,%eax
c010511b:	85 c0                	test   %eax,%eax
c010511d:	74 07                	je     c0105126 <perm2str+0x14>
c010511f:	b8 75 00 00 00       	mov    $0x75,%eax
c0105124:	eb 05                	jmp    c010512b <perm2str+0x19>
c0105126:	b8 2d 00 00 00       	mov    $0x2d,%eax
c010512b:	a2 48 89 11 c0       	mov    %al,0xc0118948
    str[1] = 'r';
c0105130:	c6 05 49 89 11 c0 72 	movb   $0x72,0xc0118949
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0105137:	8b 45 08             	mov    0x8(%ebp),%eax
c010513a:	83 e0 02             	and    $0x2,%eax
c010513d:	85 c0                	test   %eax,%eax
c010513f:	74 07                	je     c0105148 <perm2str+0x36>
c0105141:	b8 77 00 00 00       	mov    $0x77,%eax
c0105146:	eb 05                	jmp    c010514d <perm2str+0x3b>
c0105148:	b8 2d 00 00 00       	mov    $0x2d,%eax
c010514d:	a2 4a 89 11 c0       	mov    %al,0xc011894a
    str[3] = '\0';
c0105152:	c6 05 4b 89 11 c0 00 	movb   $0x0,0xc011894b
    return str;
c0105159:	b8 48 89 11 c0       	mov    $0xc0118948,%eax
}
c010515e:	5d                   	pop    %ebp
c010515f:	c3                   	ret    

c0105160 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0105160:	55                   	push   %ebp
c0105161:	89 e5                	mov    %esp,%ebp
c0105163:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0105166:	8b 45 10             	mov    0x10(%ebp),%eax
c0105169:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010516c:	72 0a                	jb     c0105178 <get_pgtable_items+0x18>
        return 0;
c010516e:	b8 00 00 00 00       	mov    $0x0,%eax
c0105173:	e9 9c 00 00 00       	jmp    c0105214 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0105178:	eb 04                	jmp    c010517e <get_pgtable_items+0x1e>
        start ++;
c010517a:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c010517e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105181:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105184:	73 18                	jae    c010519e <get_pgtable_items+0x3e>
c0105186:	8b 45 10             	mov    0x10(%ebp),%eax
c0105189:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105190:	8b 45 14             	mov    0x14(%ebp),%eax
c0105193:	01 d0                	add    %edx,%eax
c0105195:	8b 00                	mov    (%eax),%eax
c0105197:	83 e0 01             	and    $0x1,%eax
c010519a:	85 c0                	test   %eax,%eax
c010519c:	74 dc                	je     c010517a <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c010519e:	8b 45 10             	mov    0x10(%ebp),%eax
c01051a1:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01051a4:	73 69                	jae    c010520f <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c01051a6:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c01051aa:	74 08                	je     c01051b4 <get_pgtable_items+0x54>
            *left_store = start;
c01051ac:	8b 45 18             	mov    0x18(%ebp),%eax
c01051af:	8b 55 10             	mov    0x10(%ebp),%edx
c01051b2:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c01051b4:	8b 45 10             	mov    0x10(%ebp),%eax
c01051b7:	8d 50 01             	lea    0x1(%eax),%edx
c01051ba:	89 55 10             	mov    %edx,0x10(%ebp)
c01051bd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01051c4:	8b 45 14             	mov    0x14(%ebp),%eax
c01051c7:	01 d0                	add    %edx,%eax
c01051c9:	8b 00                	mov    (%eax),%eax
c01051cb:	83 e0 07             	and    $0x7,%eax
c01051ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01051d1:	eb 04                	jmp    c01051d7 <get_pgtable_items+0x77>
            start ++;
c01051d3:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c01051d7:	8b 45 10             	mov    0x10(%ebp),%eax
c01051da:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01051dd:	73 1d                	jae    c01051fc <get_pgtable_items+0x9c>
c01051df:	8b 45 10             	mov    0x10(%ebp),%eax
c01051e2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01051e9:	8b 45 14             	mov    0x14(%ebp),%eax
c01051ec:	01 d0                	add    %edx,%eax
c01051ee:	8b 00                	mov    (%eax),%eax
c01051f0:	83 e0 07             	and    $0x7,%eax
c01051f3:	89 c2                	mov    %eax,%edx
c01051f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01051f8:	39 c2                	cmp    %eax,%edx
c01051fa:	74 d7                	je     c01051d3 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c01051fc:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105200:	74 08                	je     c010520a <get_pgtable_items+0xaa>
            *right_store = start;
c0105202:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105205:	8b 55 10             	mov    0x10(%ebp),%edx
c0105208:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c010520a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010520d:	eb 05                	jmp    c0105214 <get_pgtable_items+0xb4>
    }
    return 0;
c010520f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105214:	c9                   	leave  
c0105215:	c3                   	ret    

c0105216 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0105216:	55                   	push   %ebp
c0105217:	89 e5                	mov    %esp,%ebp
c0105219:	57                   	push   %edi
c010521a:	56                   	push   %esi
c010521b:	53                   	push   %ebx
c010521c:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c010521f:	c7 04 24 04 6f 10 c0 	movl   $0xc0106f04,(%esp)
c0105226:	e8 11 b1 ff ff       	call   c010033c <cprintf>
    size_t left, right = 0, perm;
c010522b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105232:	e9 fa 00 00 00       	jmp    c0105331 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105237:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010523a:	89 04 24             	mov    %eax,(%esp)
c010523d:	e8 d0 fe ff ff       	call   c0105112 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0105242:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105245:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105248:	29 d1                	sub    %edx,%ecx
c010524a:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010524c:	89 d6                	mov    %edx,%esi
c010524e:	c1 e6 16             	shl    $0x16,%esi
c0105251:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105254:	89 d3                	mov    %edx,%ebx
c0105256:	c1 e3 16             	shl    $0x16,%ebx
c0105259:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010525c:	89 d1                	mov    %edx,%ecx
c010525e:	c1 e1 16             	shl    $0x16,%ecx
c0105261:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0105264:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105267:	29 d7                	sub    %edx,%edi
c0105269:	89 fa                	mov    %edi,%edx
c010526b:	89 44 24 14          	mov    %eax,0x14(%esp)
c010526f:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105273:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105277:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010527b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010527f:	c7 04 24 35 6f 10 c0 	movl   $0xc0106f35,(%esp)
c0105286:	e8 b1 b0 ff ff       	call   c010033c <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c010528b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010528e:	c1 e0 0a             	shl    $0xa,%eax
c0105291:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105294:	eb 54                	jmp    c01052ea <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105296:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105299:	89 04 24             	mov    %eax,(%esp)
c010529c:	e8 71 fe ff ff       	call   c0105112 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01052a1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01052a4:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01052a7:	29 d1                	sub    %edx,%ecx
c01052a9:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01052ab:	89 d6                	mov    %edx,%esi
c01052ad:	c1 e6 0c             	shl    $0xc,%esi
c01052b0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01052b3:	89 d3                	mov    %edx,%ebx
c01052b5:	c1 e3 0c             	shl    $0xc,%ebx
c01052b8:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01052bb:	c1 e2 0c             	shl    $0xc,%edx
c01052be:	89 d1                	mov    %edx,%ecx
c01052c0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c01052c3:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01052c6:	29 d7                	sub    %edx,%edi
c01052c8:	89 fa                	mov    %edi,%edx
c01052ca:	89 44 24 14          	mov    %eax,0x14(%esp)
c01052ce:	89 74 24 10          	mov    %esi,0x10(%esp)
c01052d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01052d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01052da:	89 54 24 04          	mov    %edx,0x4(%esp)
c01052de:	c7 04 24 54 6f 10 c0 	movl   $0xc0106f54,(%esp)
c01052e5:	e8 52 b0 ff ff       	call   c010033c <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01052ea:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c01052ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01052f2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01052f5:	89 ce                	mov    %ecx,%esi
c01052f7:	c1 e6 0a             	shl    $0xa,%esi
c01052fa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01052fd:	89 cb                	mov    %ecx,%ebx
c01052ff:	c1 e3 0a             	shl    $0xa,%ebx
c0105302:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c0105305:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0105309:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c010530c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0105310:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105314:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105318:	89 74 24 04          	mov    %esi,0x4(%esp)
c010531c:	89 1c 24             	mov    %ebx,(%esp)
c010531f:	e8 3c fe ff ff       	call   c0105160 <get_pgtable_items>
c0105324:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105327:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010532b:	0f 85 65 ff ff ff    	jne    c0105296 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105331:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0105336:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105339:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c010533c:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0105340:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0105343:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0105347:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010534b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010534f:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0105356:	00 
c0105357:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010535e:	e8 fd fd ff ff       	call   c0105160 <get_pgtable_items>
c0105363:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105366:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010536a:	0f 85 c7 fe ff ff    	jne    c0105237 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0105370:	c7 04 24 78 6f 10 c0 	movl   $0xc0106f78,(%esp)
c0105377:	e8 c0 af ff ff       	call   c010033c <cprintf>
}
c010537c:	83 c4 4c             	add    $0x4c,%esp
c010537f:	5b                   	pop    %ebx
c0105380:	5e                   	pop    %esi
c0105381:	5f                   	pop    %edi
c0105382:	5d                   	pop    %ebp
c0105383:	c3                   	ret    

c0105384 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0105384:	55                   	push   %ebp
c0105385:	89 e5                	mov    %esp,%ebp
c0105387:	83 ec 58             	sub    $0x58,%esp
c010538a:	8b 45 10             	mov    0x10(%ebp),%eax
c010538d:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105390:	8b 45 14             	mov    0x14(%ebp),%eax
c0105393:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0105396:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105399:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010539c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010539f:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01053a2:	8b 45 18             	mov    0x18(%ebp),%eax
c01053a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01053a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01053ab:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01053ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01053b1:	89 55 f0             	mov    %edx,-0x10(%ebp)
c01053b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01053b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01053ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01053be:	74 1c                	je     c01053dc <printnum+0x58>
c01053c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01053c3:	ba 00 00 00 00       	mov    $0x0,%edx
c01053c8:	f7 75 e4             	divl   -0x1c(%ebp)
c01053cb:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01053ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01053d1:	ba 00 00 00 00       	mov    $0x0,%edx
c01053d6:	f7 75 e4             	divl   -0x1c(%ebp)
c01053d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01053dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01053df:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01053e2:	f7 75 e4             	divl   -0x1c(%ebp)
c01053e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01053e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01053eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01053ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01053f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01053f4:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01053f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01053fa:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01053fd:	8b 45 18             	mov    0x18(%ebp),%eax
c0105400:	ba 00 00 00 00       	mov    $0x0,%edx
c0105405:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0105408:	77 56                	ja     c0105460 <printnum+0xdc>
c010540a:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010540d:	72 05                	jb     c0105414 <printnum+0x90>
c010540f:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0105412:	77 4c                	ja     c0105460 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0105414:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105417:	8d 50 ff             	lea    -0x1(%eax),%edx
c010541a:	8b 45 20             	mov    0x20(%ebp),%eax
c010541d:	89 44 24 18          	mov    %eax,0x18(%esp)
c0105421:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105425:	8b 45 18             	mov    0x18(%ebp),%eax
c0105428:	89 44 24 10          	mov    %eax,0x10(%esp)
c010542c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010542f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105432:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105436:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010543a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010543d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105441:	8b 45 08             	mov    0x8(%ebp),%eax
c0105444:	89 04 24             	mov    %eax,(%esp)
c0105447:	e8 38 ff ff ff       	call   c0105384 <printnum>
c010544c:	eb 1c                	jmp    c010546a <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010544e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105451:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105455:	8b 45 20             	mov    0x20(%ebp),%eax
c0105458:	89 04 24             	mov    %eax,(%esp)
c010545b:	8b 45 08             	mov    0x8(%ebp),%eax
c010545e:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c0105460:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c0105464:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105468:	7f e4                	jg     c010544e <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010546a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010546d:	05 2c 70 10 c0       	add    $0xc010702c,%eax
c0105472:	0f b6 00             	movzbl (%eax),%eax
c0105475:	0f be c0             	movsbl %al,%eax
c0105478:	8b 55 0c             	mov    0xc(%ebp),%edx
c010547b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010547f:	89 04 24             	mov    %eax,(%esp)
c0105482:	8b 45 08             	mov    0x8(%ebp),%eax
c0105485:	ff d0                	call   *%eax
}
c0105487:	c9                   	leave  
c0105488:	c3                   	ret    

c0105489 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0105489:	55                   	push   %ebp
c010548a:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010548c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105490:	7e 14                	jle    c01054a6 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0105492:	8b 45 08             	mov    0x8(%ebp),%eax
c0105495:	8b 00                	mov    (%eax),%eax
c0105497:	8d 48 08             	lea    0x8(%eax),%ecx
c010549a:	8b 55 08             	mov    0x8(%ebp),%edx
c010549d:	89 0a                	mov    %ecx,(%edx)
c010549f:	8b 50 04             	mov    0x4(%eax),%edx
c01054a2:	8b 00                	mov    (%eax),%eax
c01054a4:	eb 30                	jmp    c01054d6 <getuint+0x4d>
    }
    else if (lflag) {
c01054a6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01054aa:	74 16                	je     c01054c2 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c01054ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01054af:	8b 00                	mov    (%eax),%eax
c01054b1:	8d 48 04             	lea    0x4(%eax),%ecx
c01054b4:	8b 55 08             	mov    0x8(%ebp),%edx
c01054b7:	89 0a                	mov    %ecx,(%edx)
c01054b9:	8b 00                	mov    (%eax),%eax
c01054bb:	ba 00 00 00 00       	mov    $0x0,%edx
c01054c0:	eb 14                	jmp    c01054d6 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c01054c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01054c5:	8b 00                	mov    (%eax),%eax
c01054c7:	8d 48 04             	lea    0x4(%eax),%ecx
c01054ca:	8b 55 08             	mov    0x8(%ebp),%edx
c01054cd:	89 0a                	mov    %ecx,(%edx)
c01054cf:	8b 00                	mov    (%eax),%eax
c01054d1:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01054d6:	5d                   	pop    %ebp
c01054d7:	c3                   	ret    

c01054d8 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01054d8:	55                   	push   %ebp
c01054d9:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01054db:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01054df:	7e 14                	jle    c01054f5 <getint+0x1d>
        return va_arg(*ap, long long);
c01054e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01054e4:	8b 00                	mov    (%eax),%eax
c01054e6:	8d 48 08             	lea    0x8(%eax),%ecx
c01054e9:	8b 55 08             	mov    0x8(%ebp),%edx
c01054ec:	89 0a                	mov    %ecx,(%edx)
c01054ee:	8b 50 04             	mov    0x4(%eax),%edx
c01054f1:	8b 00                	mov    (%eax),%eax
c01054f3:	eb 28                	jmp    c010551d <getint+0x45>
    }
    else if (lflag) {
c01054f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01054f9:	74 12                	je     c010550d <getint+0x35>
        return va_arg(*ap, long);
c01054fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01054fe:	8b 00                	mov    (%eax),%eax
c0105500:	8d 48 04             	lea    0x4(%eax),%ecx
c0105503:	8b 55 08             	mov    0x8(%ebp),%edx
c0105506:	89 0a                	mov    %ecx,(%edx)
c0105508:	8b 00                	mov    (%eax),%eax
c010550a:	99                   	cltd   
c010550b:	eb 10                	jmp    c010551d <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010550d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105510:	8b 00                	mov    (%eax),%eax
c0105512:	8d 48 04             	lea    0x4(%eax),%ecx
c0105515:	8b 55 08             	mov    0x8(%ebp),%edx
c0105518:	89 0a                	mov    %ecx,(%edx)
c010551a:	8b 00                	mov    (%eax),%eax
c010551c:	99                   	cltd   
    }
}
c010551d:	5d                   	pop    %ebp
c010551e:	c3                   	ret    

c010551f <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010551f:	55                   	push   %ebp
c0105520:	89 e5                	mov    %esp,%ebp
c0105522:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0105525:	8d 45 14             	lea    0x14(%ebp),%eax
c0105528:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010552b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010552e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105532:	8b 45 10             	mov    0x10(%ebp),%eax
c0105535:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105539:	8b 45 0c             	mov    0xc(%ebp),%eax
c010553c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105540:	8b 45 08             	mov    0x8(%ebp),%eax
c0105543:	89 04 24             	mov    %eax,(%esp)
c0105546:	e8 02 00 00 00       	call   c010554d <vprintfmt>
    va_end(ap);
}
c010554b:	c9                   	leave  
c010554c:	c3                   	ret    

c010554d <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010554d:	55                   	push   %ebp
c010554e:	89 e5                	mov    %esp,%ebp
c0105550:	56                   	push   %esi
c0105551:	53                   	push   %ebx
c0105552:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105555:	eb 18                	jmp    c010556f <vprintfmt+0x22>
            if (ch == '\0') {
c0105557:	85 db                	test   %ebx,%ebx
c0105559:	75 05                	jne    c0105560 <vprintfmt+0x13>
                return;
c010555b:	e9 d1 03 00 00       	jmp    c0105931 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c0105560:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105563:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105567:	89 1c 24             	mov    %ebx,(%esp)
c010556a:	8b 45 08             	mov    0x8(%ebp),%eax
c010556d:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010556f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105572:	8d 50 01             	lea    0x1(%eax),%edx
c0105575:	89 55 10             	mov    %edx,0x10(%ebp)
c0105578:	0f b6 00             	movzbl (%eax),%eax
c010557b:	0f b6 d8             	movzbl %al,%ebx
c010557e:	83 fb 25             	cmp    $0x25,%ebx
c0105581:	75 d4                	jne    c0105557 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c0105583:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0105587:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010558e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105591:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0105594:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010559b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010559e:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c01055a1:	8b 45 10             	mov    0x10(%ebp),%eax
c01055a4:	8d 50 01             	lea    0x1(%eax),%edx
c01055a7:	89 55 10             	mov    %edx,0x10(%ebp)
c01055aa:	0f b6 00             	movzbl (%eax),%eax
c01055ad:	0f b6 d8             	movzbl %al,%ebx
c01055b0:	8d 43 dd             	lea    -0x23(%ebx),%eax
c01055b3:	83 f8 55             	cmp    $0x55,%eax
c01055b6:	0f 87 44 03 00 00    	ja     c0105900 <vprintfmt+0x3b3>
c01055bc:	8b 04 85 50 70 10 c0 	mov    -0x3fef8fb0(,%eax,4),%eax
c01055c3:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c01055c5:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c01055c9:	eb d6                	jmp    c01055a1 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c01055cb:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c01055cf:	eb d0                	jmp    c01055a1 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01055d1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c01055d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01055db:	89 d0                	mov    %edx,%eax
c01055dd:	c1 e0 02             	shl    $0x2,%eax
c01055e0:	01 d0                	add    %edx,%eax
c01055e2:	01 c0                	add    %eax,%eax
c01055e4:	01 d8                	add    %ebx,%eax
c01055e6:	83 e8 30             	sub    $0x30,%eax
c01055e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c01055ec:	8b 45 10             	mov    0x10(%ebp),%eax
c01055ef:	0f b6 00             	movzbl (%eax),%eax
c01055f2:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c01055f5:	83 fb 2f             	cmp    $0x2f,%ebx
c01055f8:	7e 0b                	jle    c0105605 <vprintfmt+0xb8>
c01055fa:	83 fb 39             	cmp    $0x39,%ebx
c01055fd:	7f 06                	jg     c0105605 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01055ff:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c0105603:	eb d3                	jmp    c01055d8 <vprintfmt+0x8b>
            goto process_precision;
c0105605:	eb 33                	jmp    c010563a <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c0105607:	8b 45 14             	mov    0x14(%ebp),%eax
c010560a:	8d 50 04             	lea    0x4(%eax),%edx
c010560d:	89 55 14             	mov    %edx,0x14(%ebp)
c0105610:	8b 00                	mov    (%eax),%eax
c0105612:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0105615:	eb 23                	jmp    c010563a <vprintfmt+0xed>

        case '.':
            if (width < 0)
c0105617:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010561b:	79 0c                	jns    c0105629 <vprintfmt+0xdc>
                width = 0;
c010561d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0105624:	e9 78 ff ff ff       	jmp    c01055a1 <vprintfmt+0x54>
c0105629:	e9 73 ff ff ff       	jmp    c01055a1 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c010562e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0105635:	e9 67 ff ff ff       	jmp    c01055a1 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c010563a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010563e:	79 12                	jns    c0105652 <vprintfmt+0x105>
                width = precision, precision = -1;
c0105640:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105643:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105646:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010564d:	e9 4f ff ff ff       	jmp    c01055a1 <vprintfmt+0x54>
c0105652:	e9 4a ff ff ff       	jmp    c01055a1 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0105657:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010565b:	e9 41 ff ff ff       	jmp    c01055a1 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105660:	8b 45 14             	mov    0x14(%ebp),%eax
c0105663:	8d 50 04             	lea    0x4(%eax),%edx
c0105666:	89 55 14             	mov    %edx,0x14(%ebp)
c0105669:	8b 00                	mov    (%eax),%eax
c010566b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010566e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105672:	89 04 24             	mov    %eax,(%esp)
c0105675:	8b 45 08             	mov    0x8(%ebp),%eax
c0105678:	ff d0                	call   *%eax
            break;
c010567a:	e9 ac 02 00 00       	jmp    c010592b <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010567f:	8b 45 14             	mov    0x14(%ebp),%eax
c0105682:	8d 50 04             	lea    0x4(%eax),%edx
c0105685:	89 55 14             	mov    %edx,0x14(%ebp)
c0105688:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010568a:	85 db                	test   %ebx,%ebx
c010568c:	79 02                	jns    c0105690 <vprintfmt+0x143>
                err = -err;
c010568e:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0105690:	83 fb 06             	cmp    $0x6,%ebx
c0105693:	7f 0b                	jg     c01056a0 <vprintfmt+0x153>
c0105695:	8b 34 9d 10 70 10 c0 	mov    -0x3fef8ff0(,%ebx,4),%esi
c010569c:	85 f6                	test   %esi,%esi
c010569e:	75 23                	jne    c01056c3 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c01056a0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01056a4:	c7 44 24 08 3d 70 10 	movl   $0xc010703d,0x8(%esp)
c01056ab:	c0 
c01056ac:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056af:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01056b6:	89 04 24             	mov    %eax,(%esp)
c01056b9:	e8 61 fe ff ff       	call   c010551f <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c01056be:	e9 68 02 00 00       	jmp    c010592b <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c01056c3:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01056c7:	c7 44 24 08 46 70 10 	movl   $0xc0107046,0x8(%esp)
c01056ce:	c0 
c01056cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01056d9:	89 04 24             	mov    %eax,(%esp)
c01056dc:	e8 3e fe ff ff       	call   c010551f <printfmt>
            }
            break;
c01056e1:	e9 45 02 00 00       	jmp    c010592b <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c01056e6:	8b 45 14             	mov    0x14(%ebp),%eax
c01056e9:	8d 50 04             	lea    0x4(%eax),%edx
c01056ec:	89 55 14             	mov    %edx,0x14(%ebp)
c01056ef:	8b 30                	mov    (%eax),%esi
c01056f1:	85 f6                	test   %esi,%esi
c01056f3:	75 05                	jne    c01056fa <vprintfmt+0x1ad>
                p = "(null)";
c01056f5:	be 49 70 10 c0       	mov    $0xc0107049,%esi
            }
            if (width > 0 && padc != '-') {
c01056fa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01056fe:	7e 3e                	jle    c010573e <vprintfmt+0x1f1>
c0105700:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0105704:	74 38                	je     c010573e <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105706:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c0105709:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010570c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105710:	89 34 24             	mov    %esi,(%esp)
c0105713:	e8 15 03 00 00       	call   c0105a2d <strnlen>
c0105718:	29 c3                	sub    %eax,%ebx
c010571a:	89 d8                	mov    %ebx,%eax
c010571c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010571f:	eb 17                	jmp    c0105738 <vprintfmt+0x1eb>
                    putch(padc, putdat);
c0105721:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0105725:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105728:	89 54 24 04          	mov    %edx,0x4(%esp)
c010572c:	89 04 24             	mov    %eax,(%esp)
c010572f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105732:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105734:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105738:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010573c:	7f e3                	jg     c0105721 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010573e:	eb 38                	jmp    c0105778 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105740:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105744:	74 1f                	je     c0105765 <vprintfmt+0x218>
c0105746:	83 fb 1f             	cmp    $0x1f,%ebx
c0105749:	7e 05                	jle    c0105750 <vprintfmt+0x203>
c010574b:	83 fb 7e             	cmp    $0x7e,%ebx
c010574e:	7e 15                	jle    c0105765 <vprintfmt+0x218>
                    putch('?', putdat);
c0105750:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105753:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105757:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010575e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105761:	ff d0                	call   *%eax
c0105763:	eb 0f                	jmp    c0105774 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c0105765:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105768:	89 44 24 04          	mov    %eax,0x4(%esp)
c010576c:	89 1c 24             	mov    %ebx,(%esp)
c010576f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105772:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105774:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105778:	89 f0                	mov    %esi,%eax
c010577a:	8d 70 01             	lea    0x1(%eax),%esi
c010577d:	0f b6 00             	movzbl (%eax),%eax
c0105780:	0f be d8             	movsbl %al,%ebx
c0105783:	85 db                	test   %ebx,%ebx
c0105785:	74 10                	je     c0105797 <vprintfmt+0x24a>
c0105787:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010578b:	78 b3                	js     c0105740 <vprintfmt+0x1f3>
c010578d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c0105791:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105795:	79 a9                	jns    c0105740 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0105797:	eb 17                	jmp    c01057b0 <vprintfmt+0x263>
                putch(' ', putdat);
c0105799:	8b 45 0c             	mov    0xc(%ebp),%eax
c010579c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057a0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01057a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01057aa:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c01057ac:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01057b0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01057b4:	7f e3                	jg     c0105799 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c01057b6:	e9 70 01 00 00       	jmp    c010592b <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c01057bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01057be:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057c2:	8d 45 14             	lea    0x14(%ebp),%eax
c01057c5:	89 04 24             	mov    %eax,(%esp)
c01057c8:	e8 0b fd ff ff       	call   c01054d8 <getint>
c01057cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01057d0:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c01057d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01057d9:	85 d2                	test   %edx,%edx
c01057db:	79 26                	jns    c0105803 <vprintfmt+0x2b6>
                putch('-', putdat);
c01057dd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057e0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057e4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c01057eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01057ee:	ff d0                	call   *%eax
                num = -(long long)num;
c01057f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01057f6:	f7 d8                	neg    %eax
c01057f8:	83 d2 00             	adc    $0x0,%edx
c01057fb:	f7 da                	neg    %edx
c01057fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105800:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0105803:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010580a:	e9 a8 00 00 00       	jmp    c01058b7 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010580f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105812:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105816:	8d 45 14             	lea    0x14(%ebp),%eax
c0105819:	89 04 24             	mov    %eax,(%esp)
c010581c:	e8 68 fc ff ff       	call   c0105489 <getuint>
c0105821:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105824:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0105827:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010582e:	e9 84 00 00 00       	jmp    c01058b7 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105833:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105836:	89 44 24 04          	mov    %eax,0x4(%esp)
c010583a:	8d 45 14             	lea    0x14(%ebp),%eax
c010583d:	89 04 24             	mov    %eax,(%esp)
c0105840:	e8 44 fc ff ff       	call   c0105489 <getuint>
c0105845:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105848:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010584b:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0105852:	eb 63                	jmp    c01058b7 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c0105854:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105857:	89 44 24 04          	mov    %eax,0x4(%esp)
c010585b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0105862:	8b 45 08             	mov    0x8(%ebp),%eax
c0105865:	ff d0                	call   *%eax
            putch('x', putdat);
c0105867:	8b 45 0c             	mov    0xc(%ebp),%eax
c010586a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010586e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0105875:	8b 45 08             	mov    0x8(%ebp),%eax
c0105878:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010587a:	8b 45 14             	mov    0x14(%ebp),%eax
c010587d:	8d 50 04             	lea    0x4(%eax),%edx
c0105880:	89 55 14             	mov    %edx,0x14(%ebp)
c0105883:	8b 00                	mov    (%eax),%eax
c0105885:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105888:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010588f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0105896:	eb 1f                	jmp    c01058b7 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0105898:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010589b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010589f:	8d 45 14             	lea    0x14(%ebp),%eax
c01058a2:	89 04 24             	mov    %eax,(%esp)
c01058a5:	e8 df fb ff ff       	call   c0105489 <getuint>
c01058aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058ad:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c01058b0:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c01058b7:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c01058bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01058be:	89 54 24 18          	mov    %edx,0x18(%esp)
c01058c2:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01058c5:	89 54 24 14          	mov    %edx,0x14(%esp)
c01058c9:	89 44 24 10          	mov    %eax,0x10(%esp)
c01058cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01058d3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01058d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01058db:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058de:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01058e5:	89 04 24             	mov    %eax,(%esp)
c01058e8:	e8 97 fa ff ff       	call   c0105384 <printnum>
            break;
c01058ed:	eb 3c                	jmp    c010592b <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c01058ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058f2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058f6:	89 1c 24             	mov    %ebx,(%esp)
c01058f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01058fc:	ff d0                	call   *%eax
            break;
c01058fe:	eb 2b                	jmp    c010592b <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0105900:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105903:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105907:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c010590e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105911:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0105913:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105917:	eb 04                	jmp    c010591d <vprintfmt+0x3d0>
c0105919:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010591d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105920:	83 e8 01             	sub    $0x1,%eax
c0105923:	0f b6 00             	movzbl (%eax),%eax
c0105926:	3c 25                	cmp    $0x25,%al
c0105928:	75 ef                	jne    c0105919 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c010592a:	90                   	nop
        }
    }
c010592b:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010592c:	e9 3e fc ff ff       	jmp    c010556f <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c0105931:	83 c4 40             	add    $0x40,%esp
c0105934:	5b                   	pop    %ebx
c0105935:	5e                   	pop    %esi
c0105936:	5d                   	pop    %ebp
c0105937:	c3                   	ret    

c0105938 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0105938:	55                   	push   %ebp
c0105939:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010593b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010593e:	8b 40 08             	mov    0x8(%eax),%eax
c0105941:	8d 50 01             	lea    0x1(%eax),%edx
c0105944:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105947:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010594a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010594d:	8b 10                	mov    (%eax),%edx
c010594f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105952:	8b 40 04             	mov    0x4(%eax),%eax
c0105955:	39 c2                	cmp    %eax,%edx
c0105957:	73 12                	jae    c010596b <sprintputch+0x33>
        *b->buf ++ = ch;
c0105959:	8b 45 0c             	mov    0xc(%ebp),%eax
c010595c:	8b 00                	mov    (%eax),%eax
c010595e:	8d 48 01             	lea    0x1(%eax),%ecx
c0105961:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105964:	89 0a                	mov    %ecx,(%edx)
c0105966:	8b 55 08             	mov    0x8(%ebp),%edx
c0105969:	88 10                	mov    %dl,(%eax)
    }
}
c010596b:	5d                   	pop    %ebp
c010596c:	c3                   	ret    

c010596d <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010596d:	55                   	push   %ebp
c010596e:	89 e5                	mov    %esp,%ebp
c0105970:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0105973:	8d 45 14             	lea    0x14(%ebp),%eax
c0105976:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0105979:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010597c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105980:	8b 45 10             	mov    0x10(%ebp),%eax
c0105983:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105987:	8b 45 0c             	mov    0xc(%ebp),%eax
c010598a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010598e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105991:	89 04 24             	mov    %eax,(%esp)
c0105994:	e8 08 00 00 00       	call   c01059a1 <vsnprintf>
c0105999:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010599c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010599f:	c9                   	leave  
c01059a0:	c3                   	ret    

c01059a1 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c01059a1:	55                   	push   %ebp
c01059a2:	89 e5                	mov    %esp,%ebp
c01059a4:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c01059a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01059aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01059ad:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059b0:	8d 50 ff             	lea    -0x1(%eax),%edx
c01059b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01059b6:	01 d0                	add    %edx,%eax
c01059b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c01059c2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01059c6:	74 0a                	je     c01059d2 <vsnprintf+0x31>
c01059c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01059cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059ce:	39 c2                	cmp    %eax,%edx
c01059d0:	76 07                	jbe    c01059d9 <vsnprintf+0x38>
        return -E_INVAL;
c01059d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01059d7:	eb 2a                	jmp    c0105a03 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c01059d9:	8b 45 14             	mov    0x14(%ebp),%eax
c01059dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01059e0:	8b 45 10             	mov    0x10(%ebp),%eax
c01059e3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01059e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
c01059ea:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059ee:	c7 04 24 38 59 10 c0 	movl   $0xc0105938,(%esp)
c01059f5:	e8 53 fb ff ff       	call   c010554d <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c01059fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059fd:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105a03:	c9                   	leave  
c0105a04:	c3                   	ret    

c0105a05 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0105a05:	55                   	push   %ebp
c0105a06:	89 e5                	mov    %esp,%ebp
c0105a08:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105a0b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0105a12:	eb 04                	jmp    c0105a18 <strlen+0x13>
        cnt ++;
c0105a14:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0105a18:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a1b:	8d 50 01             	lea    0x1(%eax),%edx
c0105a1e:	89 55 08             	mov    %edx,0x8(%ebp)
c0105a21:	0f b6 00             	movzbl (%eax),%eax
c0105a24:	84 c0                	test   %al,%al
c0105a26:	75 ec                	jne    c0105a14 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0105a28:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105a2b:	c9                   	leave  
c0105a2c:	c3                   	ret    

c0105a2d <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0105a2d:	55                   	push   %ebp
c0105a2e:	89 e5                	mov    %esp,%ebp
c0105a30:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105a33:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105a3a:	eb 04                	jmp    c0105a40 <strnlen+0x13>
        cnt ++;
c0105a3c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0105a40:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105a43:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105a46:	73 10                	jae    c0105a58 <strnlen+0x2b>
c0105a48:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a4b:	8d 50 01             	lea    0x1(%eax),%edx
c0105a4e:	89 55 08             	mov    %edx,0x8(%ebp)
c0105a51:	0f b6 00             	movzbl (%eax),%eax
c0105a54:	84 c0                	test   %al,%al
c0105a56:	75 e4                	jne    c0105a3c <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0105a58:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105a5b:	c9                   	leave  
c0105a5c:	c3                   	ret    

c0105a5d <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105a5d:	55                   	push   %ebp
c0105a5e:	89 e5                	mov    %esp,%ebp
c0105a60:	57                   	push   %edi
c0105a61:	56                   	push   %esi
c0105a62:	83 ec 20             	sub    $0x20,%esp
c0105a65:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a68:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0105a71:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a77:	89 d1                	mov    %edx,%ecx
c0105a79:	89 c2                	mov    %eax,%edx
c0105a7b:	89 ce                	mov    %ecx,%esi
c0105a7d:	89 d7                	mov    %edx,%edi
c0105a7f:	ac                   	lods   %ds:(%esi),%al
c0105a80:	aa                   	stos   %al,%es:(%edi)
c0105a81:	84 c0                	test   %al,%al
c0105a83:	75 fa                	jne    c0105a7f <strcpy+0x22>
c0105a85:	89 fa                	mov    %edi,%edx
c0105a87:	89 f1                	mov    %esi,%ecx
c0105a89:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105a8c:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105a8f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0105a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105a95:	83 c4 20             	add    $0x20,%esp
c0105a98:	5e                   	pop    %esi
c0105a99:	5f                   	pop    %edi
c0105a9a:	5d                   	pop    %ebp
c0105a9b:	c3                   	ret    

c0105a9c <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105a9c:	55                   	push   %ebp
c0105a9d:	89 e5                	mov    %esp,%ebp
c0105a9f:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0105aa2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105aa5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105aa8:	eb 21                	jmp    c0105acb <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0105aaa:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105aad:	0f b6 10             	movzbl (%eax),%edx
c0105ab0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105ab3:	88 10                	mov    %dl,(%eax)
c0105ab5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105ab8:	0f b6 00             	movzbl (%eax),%eax
c0105abb:	84 c0                	test   %al,%al
c0105abd:	74 04                	je     c0105ac3 <strncpy+0x27>
            src ++;
c0105abf:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0105ac3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105ac7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0105acb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105acf:	75 d9                	jne    c0105aaa <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0105ad1:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105ad4:	c9                   	leave  
c0105ad5:	c3                   	ret    

c0105ad6 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105ad6:	55                   	push   %ebp
c0105ad7:	89 e5                	mov    %esp,%ebp
c0105ad9:	57                   	push   %edi
c0105ada:	56                   	push   %esi
c0105adb:	83 ec 20             	sub    $0x20,%esp
c0105ade:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ae1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ae4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ae7:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0105aea:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105af0:	89 d1                	mov    %edx,%ecx
c0105af2:	89 c2                	mov    %eax,%edx
c0105af4:	89 ce                	mov    %ecx,%esi
c0105af6:	89 d7                	mov    %edx,%edi
c0105af8:	ac                   	lods   %ds:(%esi),%al
c0105af9:	ae                   	scas   %es:(%edi),%al
c0105afa:	75 08                	jne    c0105b04 <strcmp+0x2e>
c0105afc:	84 c0                	test   %al,%al
c0105afe:	75 f8                	jne    c0105af8 <strcmp+0x22>
c0105b00:	31 c0                	xor    %eax,%eax
c0105b02:	eb 04                	jmp    c0105b08 <strcmp+0x32>
c0105b04:	19 c0                	sbb    %eax,%eax
c0105b06:	0c 01                	or     $0x1,%al
c0105b08:	89 fa                	mov    %edi,%edx
c0105b0a:	89 f1                	mov    %esi,%ecx
c0105b0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105b0f:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105b12:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0105b15:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105b18:	83 c4 20             	add    $0x20,%esp
c0105b1b:	5e                   	pop    %esi
c0105b1c:	5f                   	pop    %edi
c0105b1d:	5d                   	pop    %ebp
c0105b1e:	c3                   	ret    

c0105b1f <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0105b1f:	55                   	push   %ebp
c0105b20:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105b22:	eb 0c                	jmp    c0105b30 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0105b24:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105b28:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105b2c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105b30:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105b34:	74 1a                	je     c0105b50 <strncmp+0x31>
c0105b36:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b39:	0f b6 00             	movzbl (%eax),%eax
c0105b3c:	84 c0                	test   %al,%al
c0105b3e:	74 10                	je     c0105b50 <strncmp+0x31>
c0105b40:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b43:	0f b6 10             	movzbl (%eax),%edx
c0105b46:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b49:	0f b6 00             	movzbl (%eax),%eax
c0105b4c:	38 c2                	cmp    %al,%dl
c0105b4e:	74 d4                	je     c0105b24 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105b50:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105b54:	74 18                	je     c0105b6e <strncmp+0x4f>
c0105b56:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b59:	0f b6 00             	movzbl (%eax),%eax
c0105b5c:	0f b6 d0             	movzbl %al,%edx
c0105b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b62:	0f b6 00             	movzbl (%eax),%eax
c0105b65:	0f b6 c0             	movzbl %al,%eax
c0105b68:	29 c2                	sub    %eax,%edx
c0105b6a:	89 d0                	mov    %edx,%eax
c0105b6c:	eb 05                	jmp    c0105b73 <strncmp+0x54>
c0105b6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105b73:	5d                   	pop    %ebp
c0105b74:	c3                   	ret    

c0105b75 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105b75:	55                   	push   %ebp
c0105b76:	89 e5                	mov    %esp,%ebp
c0105b78:	83 ec 04             	sub    $0x4,%esp
c0105b7b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b7e:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105b81:	eb 14                	jmp    c0105b97 <strchr+0x22>
        if (*s == c) {
c0105b83:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b86:	0f b6 00             	movzbl (%eax),%eax
c0105b89:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105b8c:	75 05                	jne    c0105b93 <strchr+0x1e>
            return (char *)s;
c0105b8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b91:	eb 13                	jmp    c0105ba6 <strchr+0x31>
        }
        s ++;
c0105b93:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0105b97:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b9a:	0f b6 00             	movzbl (%eax),%eax
c0105b9d:	84 c0                	test   %al,%al
c0105b9f:	75 e2                	jne    c0105b83 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0105ba1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105ba6:	c9                   	leave  
c0105ba7:	c3                   	ret    

c0105ba8 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105ba8:	55                   	push   %ebp
c0105ba9:	89 e5                	mov    %esp,%ebp
c0105bab:	83 ec 04             	sub    $0x4,%esp
c0105bae:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bb1:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105bb4:	eb 11                	jmp    c0105bc7 <strfind+0x1f>
        if (*s == c) {
c0105bb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bb9:	0f b6 00             	movzbl (%eax),%eax
c0105bbc:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105bbf:	75 02                	jne    c0105bc3 <strfind+0x1b>
            break;
c0105bc1:	eb 0e                	jmp    c0105bd1 <strfind+0x29>
        }
        s ++;
c0105bc3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0105bc7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bca:	0f b6 00             	movzbl (%eax),%eax
c0105bcd:	84 c0                	test   %al,%al
c0105bcf:	75 e5                	jne    c0105bb6 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c0105bd1:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105bd4:	c9                   	leave  
c0105bd5:	c3                   	ret    

c0105bd6 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105bd6:	55                   	push   %ebp
c0105bd7:	89 e5                	mov    %esp,%ebp
c0105bd9:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105bdc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105be3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105bea:	eb 04                	jmp    c0105bf0 <strtol+0x1a>
        s ++;
c0105bec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105bf0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bf3:	0f b6 00             	movzbl (%eax),%eax
c0105bf6:	3c 20                	cmp    $0x20,%al
c0105bf8:	74 f2                	je     c0105bec <strtol+0x16>
c0105bfa:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bfd:	0f b6 00             	movzbl (%eax),%eax
c0105c00:	3c 09                	cmp    $0x9,%al
c0105c02:	74 e8                	je     c0105bec <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0105c04:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c07:	0f b6 00             	movzbl (%eax),%eax
c0105c0a:	3c 2b                	cmp    $0x2b,%al
c0105c0c:	75 06                	jne    c0105c14 <strtol+0x3e>
        s ++;
c0105c0e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105c12:	eb 15                	jmp    c0105c29 <strtol+0x53>
    }
    else if (*s == '-') {
c0105c14:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c17:	0f b6 00             	movzbl (%eax),%eax
c0105c1a:	3c 2d                	cmp    $0x2d,%al
c0105c1c:	75 0b                	jne    c0105c29 <strtol+0x53>
        s ++, neg = 1;
c0105c1e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105c22:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105c29:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c2d:	74 06                	je     c0105c35 <strtol+0x5f>
c0105c2f:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0105c33:	75 24                	jne    c0105c59 <strtol+0x83>
c0105c35:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c38:	0f b6 00             	movzbl (%eax),%eax
c0105c3b:	3c 30                	cmp    $0x30,%al
c0105c3d:	75 1a                	jne    c0105c59 <strtol+0x83>
c0105c3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c42:	83 c0 01             	add    $0x1,%eax
c0105c45:	0f b6 00             	movzbl (%eax),%eax
c0105c48:	3c 78                	cmp    $0x78,%al
c0105c4a:	75 0d                	jne    c0105c59 <strtol+0x83>
        s += 2, base = 16;
c0105c4c:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105c50:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105c57:	eb 2a                	jmp    c0105c83 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0105c59:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c5d:	75 17                	jne    c0105c76 <strtol+0xa0>
c0105c5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c62:	0f b6 00             	movzbl (%eax),%eax
c0105c65:	3c 30                	cmp    $0x30,%al
c0105c67:	75 0d                	jne    c0105c76 <strtol+0xa0>
        s ++, base = 8;
c0105c69:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105c6d:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105c74:	eb 0d                	jmp    c0105c83 <strtol+0xad>
    }
    else if (base == 0) {
c0105c76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c7a:	75 07                	jne    c0105c83 <strtol+0xad>
        base = 10;
c0105c7c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105c83:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c86:	0f b6 00             	movzbl (%eax),%eax
c0105c89:	3c 2f                	cmp    $0x2f,%al
c0105c8b:	7e 1b                	jle    c0105ca8 <strtol+0xd2>
c0105c8d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c90:	0f b6 00             	movzbl (%eax),%eax
c0105c93:	3c 39                	cmp    $0x39,%al
c0105c95:	7f 11                	jg     c0105ca8 <strtol+0xd2>
            dig = *s - '0';
c0105c97:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c9a:	0f b6 00             	movzbl (%eax),%eax
c0105c9d:	0f be c0             	movsbl %al,%eax
c0105ca0:	83 e8 30             	sub    $0x30,%eax
c0105ca3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ca6:	eb 48                	jmp    c0105cf0 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105ca8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cab:	0f b6 00             	movzbl (%eax),%eax
c0105cae:	3c 60                	cmp    $0x60,%al
c0105cb0:	7e 1b                	jle    c0105ccd <strtol+0xf7>
c0105cb2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cb5:	0f b6 00             	movzbl (%eax),%eax
c0105cb8:	3c 7a                	cmp    $0x7a,%al
c0105cba:	7f 11                	jg     c0105ccd <strtol+0xf7>
            dig = *s - 'a' + 10;
c0105cbc:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cbf:	0f b6 00             	movzbl (%eax),%eax
c0105cc2:	0f be c0             	movsbl %al,%eax
c0105cc5:	83 e8 57             	sub    $0x57,%eax
c0105cc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ccb:	eb 23                	jmp    c0105cf0 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0105ccd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cd0:	0f b6 00             	movzbl (%eax),%eax
c0105cd3:	3c 40                	cmp    $0x40,%al
c0105cd5:	7e 3d                	jle    c0105d14 <strtol+0x13e>
c0105cd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cda:	0f b6 00             	movzbl (%eax),%eax
c0105cdd:	3c 5a                	cmp    $0x5a,%al
c0105cdf:	7f 33                	jg     c0105d14 <strtol+0x13e>
            dig = *s - 'A' + 10;
c0105ce1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ce4:	0f b6 00             	movzbl (%eax),%eax
c0105ce7:	0f be c0             	movsbl %al,%eax
c0105cea:	83 e8 37             	sub    $0x37,%eax
c0105ced:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0105cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cf3:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105cf6:	7c 02                	jl     c0105cfa <strtol+0x124>
            break;
c0105cf8:	eb 1a                	jmp    c0105d14 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c0105cfa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105cfe:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105d01:	0f af 45 10          	imul   0x10(%ebp),%eax
c0105d05:	89 c2                	mov    %eax,%edx
c0105d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d0a:	01 d0                	add    %edx,%eax
c0105d0c:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0105d0f:	e9 6f ff ff ff       	jmp    c0105c83 <strtol+0xad>

    if (endptr) {
c0105d14:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105d18:	74 08                	je     c0105d22 <strtol+0x14c>
        *endptr = (char *) s;
c0105d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d1d:	8b 55 08             	mov    0x8(%ebp),%edx
c0105d20:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0105d22:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0105d26:	74 07                	je     c0105d2f <strtol+0x159>
c0105d28:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105d2b:	f7 d8                	neg    %eax
c0105d2d:	eb 03                	jmp    c0105d32 <strtol+0x15c>
c0105d2f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0105d32:	c9                   	leave  
c0105d33:	c3                   	ret    

c0105d34 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0105d34:	55                   	push   %ebp
c0105d35:	89 e5                	mov    %esp,%ebp
c0105d37:	57                   	push   %edi
c0105d38:	83 ec 24             	sub    $0x24,%esp
c0105d3b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d3e:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0105d41:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0105d45:	8b 55 08             	mov    0x8(%ebp),%edx
c0105d48:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0105d4b:	88 45 f7             	mov    %al,-0x9(%ebp)
c0105d4e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d51:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0105d54:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0105d57:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105d5b:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105d5e:	89 d7                	mov    %edx,%edi
c0105d60:	f3 aa                	rep stos %al,%es:(%edi)
c0105d62:	89 fa                	mov    %edi,%edx
c0105d64:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105d67:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105d6a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105d6d:	83 c4 24             	add    $0x24,%esp
c0105d70:	5f                   	pop    %edi
c0105d71:	5d                   	pop    %ebp
c0105d72:	c3                   	ret    

c0105d73 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105d73:	55                   	push   %ebp
c0105d74:	89 e5                	mov    %esp,%ebp
c0105d76:	57                   	push   %edi
c0105d77:	56                   	push   %esi
c0105d78:	53                   	push   %ebx
c0105d79:	83 ec 30             	sub    $0x30,%esp
c0105d7c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d82:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d85:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105d88:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d8b:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105d8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d91:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105d94:	73 42                	jae    c0105dd8 <memmove+0x65>
c0105d96:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105d9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d9f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105da2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105da5:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105da8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105dab:	c1 e8 02             	shr    $0x2,%eax
c0105dae:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105db0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105db3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105db6:	89 d7                	mov    %edx,%edi
c0105db8:	89 c6                	mov    %eax,%esi
c0105dba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105dbc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105dbf:	83 e1 03             	and    $0x3,%ecx
c0105dc2:	74 02                	je     c0105dc6 <memmove+0x53>
c0105dc4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105dc6:	89 f0                	mov    %esi,%eax
c0105dc8:	89 fa                	mov    %edi,%edx
c0105dca:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0105dcd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105dd0:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105dd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105dd6:	eb 36                	jmp    c0105e0e <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0105dd8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ddb:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105dde:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105de1:	01 c2                	add    %eax,%edx
c0105de3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105de6:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105dec:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0105def:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105df2:	89 c1                	mov    %eax,%ecx
c0105df4:	89 d8                	mov    %ebx,%eax
c0105df6:	89 d6                	mov    %edx,%esi
c0105df8:	89 c7                	mov    %eax,%edi
c0105dfa:	fd                   	std    
c0105dfb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105dfd:	fc                   	cld    
c0105dfe:	89 f8                	mov    %edi,%eax
c0105e00:	89 f2                	mov    %esi,%edx
c0105e02:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0105e05:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0105e08:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0105e0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0105e0e:	83 c4 30             	add    $0x30,%esp
c0105e11:	5b                   	pop    %ebx
c0105e12:	5e                   	pop    %esi
c0105e13:	5f                   	pop    %edi
c0105e14:	5d                   	pop    %ebp
c0105e15:	c3                   	ret    

c0105e16 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0105e16:	55                   	push   %ebp
c0105e17:	89 e5                	mov    %esp,%ebp
c0105e19:	57                   	push   %edi
c0105e1a:	56                   	push   %esi
c0105e1b:	83 ec 20             	sub    $0x20,%esp
c0105e1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e21:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105e24:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e27:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e2a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e2d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105e30:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e33:	c1 e8 02             	shr    $0x2,%eax
c0105e36:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105e38:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105e3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e3e:	89 d7                	mov    %edx,%edi
c0105e40:	89 c6                	mov    %eax,%esi
c0105e42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105e44:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0105e47:	83 e1 03             	and    $0x3,%ecx
c0105e4a:	74 02                	je     c0105e4e <memcpy+0x38>
c0105e4c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105e4e:	89 f0                	mov    %esi,%eax
c0105e50:	89 fa                	mov    %edi,%edx
c0105e52:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105e55:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105e58:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105e5e:	83 c4 20             	add    $0x20,%esp
c0105e61:	5e                   	pop    %esi
c0105e62:	5f                   	pop    %edi
c0105e63:	5d                   	pop    %ebp
c0105e64:	c3                   	ret    

c0105e65 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0105e65:	55                   	push   %ebp
c0105e66:	89 e5                	mov    %esp,%ebp
c0105e68:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105e6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e6e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105e71:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e74:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0105e77:	eb 30                	jmp    c0105ea9 <memcmp+0x44>
        if (*s1 != *s2) {
c0105e79:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105e7c:	0f b6 10             	movzbl (%eax),%edx
c0105e7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105e82:	0f b6 00             	movzbl (%eax),%eax
c0105e85:	38 c2                	cmp    %al,%dl
c0105e87:	74 18                	je     c0105ea1 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105e89:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105e8c:	0f b6 00             	movzbl (%eax),%eax
c0105e8f:	0f b6 d0             	movzbl %al,%edx
c0105e92:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105e95:	0f b6 00             	movzbl (%eax),%eax
c0105e98:	0f b6 c0             	movzbl %al,%eax
c0105e9b:	29 c2                	sub    %eax,%edx
c0105e9d:	89 d0                	mov    %edx,%eax
c0105e9f:	eb 1a                	jmp    c0105ebb <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0105ea1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105ea5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0105ea9:	8b 45 10             	mov    0x10(%ebp),%eax
c0105eac:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105eaf:	89 55 10             	mov    %edx,0x10(%ebp)
c0105eb2:	85 c0                	test   %eax,%eax
c0105eb4:	75 c3                	jne    c0105e79 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0105eb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105ebb:	c9                   	leave  
c0105ebc:	c3                   	ret    
