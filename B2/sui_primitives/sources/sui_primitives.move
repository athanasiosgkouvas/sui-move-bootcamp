
module sui_primitives::sui_primitives {

    use std::unit_test::assert_eq;



    #[test]
    fun test_numbers() {
        let a = 50;
        let b = 50;
        assert!(a == b, 601);

        let sum = a + b;
        assert_eq!(sum, 100);

        let sub = sum - 90;
        assert!(sub == 10, 602);

        let div = sub / 3 ;
        assert_eq!(div, 3);
    }

    #[test]
    fun test_overflow() {
        let a: u8 = 200;
        let b: u8 = 200;

        let sum: u16 = (a as u16) + (b as u16);

        assert!(sum == 400, 604) ;
    }

    #[test]
    fun test_mutability() {

    }

    #[test]
    fun test_boolean(){

    }

    #[test]
    fun test_loop(){
        let fact = 5;
        let mut result : u256 = 1;
        let mut i =2;
        while (i <= fact){
            result = result * i;
            i = i+1;
        };
        std::debug::print(&result);
        assert_eq!(result, 120);
    }

    #[test]
    fun test_vector(){
        let mut myVec: vector<u8> = vector[10, 20, 30];
        let mut myOtherVec : vector<u8> = vector::empty();

        assert!(myOtherVec.is_empty() == true);
        assert!(myVec.length() == 3);
        myVec.push_back(40);
        assert!(myVec.length() == 4);
        assert!(myVec[3] == 40);

        let num = myVec.pop_back();
        assert!(num == 40);
        assert!(myVec.length() == 3);

        while(myVec.length() > 0) {
            myVec.pop_back();
        };

        assert!(myVec.length() == 0);



    }

    use std::string::{String};

    #[test]
    fun test_string(){
        let myStringArr : vector<u8>    = b"Hello, World!";


    }

    #[test]
    fun test_string2(){
        let myStringArr = b"Hello, World!";

        let mut i: u64 = 0;
        let mut indexOfW: u64 = 0;

        while(i < myStringArr.length()) {
            indexOfW = if(myStringArr[i] == 87) { i } else { indexOfW };
            i = i+ 1;
        };

        assert!(indexOfW == 7);

    }

}
