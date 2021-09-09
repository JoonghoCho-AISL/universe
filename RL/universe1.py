import gym
import universe # register universe environment
import random

#자동차 레이싱 시뮬레이션 환경 생성
env = gym.make('flashgames.NeonRace-v0')
env.configure(remotes=1) #automatically creates a local docker container

#Move left
left = [('KeyEvent', 'ArrowUp', True), ('KeyEvent', 'ArrowLeft', True),
        ('KeyEvent', 'ArrowRight', False)]

#Move right
right = [('KeyEvent', 'ArrowUp', True),('KeyEvent', 'ArrowLeft', False), 
        ('KeyEvent', 'ArrowRight', True)]

#Move forward
forward = [('KeyEvent', 'ArrowUp', True), ('KeyEvent', 'ArrowRight', False),
        ('KeyEvent', 'ArrowLeft', False), ('KeyEvent', 'n', True)]

# We use turn variable for deciding whether to turn or not
turn = 0
# We store all the rewards in rewards list
rewards = []
# We will use buffer as some threshold
buffer_size = 100
# We will initially set action as forward, which just move the car forward
# without any turn
action = forward

# 무한 반복문으로 게임 에이전트가 학습하도록 구성
while True:
    turn -= 1
    # turn을 하지 않기 위해 0보다 작게 하면 직진이 가능하다.
    if turn <=0:
        action = forward
        turn = 0
    # env.step()을 하용하여 하나의 타임 스텝동안 행동하도록 함
    action_n = [action for ob in observation_n]
    observation_n, reward_n, done_n, info = env.step(action_n)
    """
    observation_n : 자동차의 상태
    reward_n : 이전의 행동으로부터 얻는 보상 (자동차가 벽에 막히지 않는 경우)
    done_n : 게임 오버인 경우 참으로 설정 (에피소드 끝)
    info_n : 디버깅 용도로 사용
    """
    # 0~1 사이의 숫자로 0.5보다 작으면 오른쪽, 0.5보다 크면 왼쪽으로 움직이도록 구성
    # 행동에 따른 보상을 구함
    # 보상에 따라 정책을 개선
    if len(rewards) >= buffer_size:
        mean = sum(rewards)/len(rewards)
        if mean == 0:
            turn = 20
            if random.random() < 0.5:
                action = right
            else:
                action = left
        rewards = []
    # env.render()를 이용하여 환경 업데이트
    env.render()