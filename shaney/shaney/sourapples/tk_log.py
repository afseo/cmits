# --- BEGIN DISCLAIMER ---
# Those who use this do so at their own risk;
# AFSEO does not provide maintenance nor support.
# --- END DISCLAIMER ---
# --- BEGIN AFSEO_DATA_RIGHTS ---
# This is a work of the U.S. Government and is placed
# into the public domain in accordance with 17 USC Sec.
# 105. Those who redistribute or derive from this work
# are requested to include a reference to the original,
# at <https://github.com/afseo/cmits>, for example by
# including this notice in its entirety in derived works.
# --- END AFSEO_DATA_RIGHTS ---
import logging
from Tkinter import *
from threading import Thread
from threading import Event as TEvent
from Queue import Queue, Empty
from time import sleep
import sys

class LogText(Frame):
    CHECK_QUEUE_EVERY_MS = 100

    def __init__(self, log_queue, master, width=80, height=10):
        Frame.__init__(self, master)
        self.q = log_queue
        self.lineCount = 0
        self.height = height
        self.width = width
        self.config(padx=3, pady=3, borderwidth=1, relief=SUNKEN)
        Label(self, text='Events').pack(anchor=W)
        self.progressVscroll = Scrollbar(self, orient=VERTICAL)
        self.progressText = Text(self, height=self.height, 
                                 width=self.width, relief=SUNKEN,
                                 borderwidth=1,
                                 yscrollcommand=self.progressVscroll.set)
        self.progressVscroll.config(command = self.progressText.yview)
        self.progressText['xscrollcommand'] = self.progressVscroll.set
        self.progressText.pack(side=LEFT, fill=BOTH, expand=1)
        self.progressVscroll.pack(side=LEFT, fill=Y)
        self.after(self.CHECK_QUEUE_EVERY_MS, self.check_queue)

    def check_queue(self):
        keep_trying = True
        # consume all messages in queue
        while keep_trying:
            try:
                message = self.q.get(False)
                self.progress(message)
            except Empty:
                keep_trying = False
        self.after(self.CHECK_QUEUE_EVERY_MS, self.check_queue)

    def progress(self, message):
        self.progressText.insert(END, message + '\n')
        self.lineCount += len(message.split('\n'))
        self.progressText.yview_moveto(1.0)
        top = (float(self.lineCount) - self.height) / self.lineCount
        if top < 0.0: top = 0.0
        self.progressVscroll.set(top, 1.0)

    def clear(self):
        self.progressText.delete('0.0', END)
        self.lineCount = 0
        self.progressVscroll.set(0.0, 1.0)



class MessageViewer(Frame):
    def __init__(self, log_queue, finished_event, master=None):
        Frame.__init__(self, master)
        self.pack(fill=BOTH, expand=1)
        self.lineCount = 0
        self._finished_event = finished_event
        self._finished_fired = False
        self.progressLogText = LogText(log_queue, master=self, height=24, width=80)
        self.progressLogText.pack(fill=BOTH, expand=1)
        buttons = Frame(self, padx=5, pady=5)
        self.okButton = Button(buttons, text='OK', command=self.quit,
                state=DISABLED)
        self.okButton.pack(side=LEFT)
        self.abortButton = Button(buttons, text='Abort', command=self.abort)
        self.abortButton.pack(side=LEFT)
        buttons.pack(fill=X)
        self.after(100, self.check_finished)

    def quit(self):
        sys.exit(0)

    def abort(self):
        sys.exit(0)

    def check_finished(self):
        if not self._finished_fired:
            if self._finished_event.isSet():
                self.finished()
                self._finished_fired = True
            else:
                self.after(100, self.check_finished)

    def finished(self):
        self.okButton['state'] = NORMAL
        self.okButton.focus_set()
        self.abortButton['state'] = DISABLED


class QueuePutHandler(logging.Handler):
    def __init__(self, queue, level=logging.NOTSET):
        logging.Handler.__init__(self, level)
        self.q = queue
    def emit(self, record):
        try:
            self.q.put(self.format(record))
        except (KeyboardInterrupt, SystemExit):
            raise
        except:
            self.handleError(record)


def generate_test_messages():
    log = logging.getLogger('slow_thread')
    for i in range(100):
        sleep(0.2)
        log.info('message %d',i)


def run_and_view_log(run_callable, level=logging.DEBUG):
    log_queue = Queue()
    finished_event = TEvent()
    root = Tk()
    app = MessageViewer(log_queue, finished_event, master=root)
    fmt = logging.Formatter(logging.BASIC_FORMAT, None)
    hdlr = QueuePutHandler(log_queue)
    hdlr.setFormatter(fmt)
    logging.root.addHandler(hdlr)
    logging.root.setLevel(level)
    def business():
        log = logging.getLogger('run_and_view_log thread')
        try:
            run_callable()
            finished_event.set()
        except:
            log.exception('Something went wrong')

    Thread(target=business).start()
    app.mainloop()
    root.destroy()
    
if __name__ == '__main__':
    run_and_view_log(generate_test_messages)
